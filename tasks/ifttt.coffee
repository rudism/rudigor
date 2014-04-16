requireDir = require "require-dir"
{parseString} = require "xml2js"

config = require "./config/ifttt.config.json"
hooks = requireDir "./ifttt-hooks"

module.exports = (app) ->
    app.get "/ifttt/hooks", (req, res) ->
        res.send JSON.stringify hooks
    app.post "/xmlrpc.php", (req, res) ->
        parseString req.rawBody, (err, result) ->
            success = true
            content = null
            method = result.methodCall.methodName[0]
            if method == "mt.supportedMethods"
                content = """
<?xml version="1.0"?>
<methodResponse><params><param><value><array><data><value><string>metaWeblog.getRecentPosts</string></value><value><string>metaWeblog.newPost</string></value><value><string>metaWeblog.getCategories</string></value></data></array></value></param></params>
"""
            else if method == "metaWeblog.newPost"
                data =
                    login: result.methodCall.params[0].param[1].value[0].string[0]
                    password: result.methodCall.params[0].param[2].value[0].string[0]
                    categories: []
                    tags: []
                for member in result.methodCall.params[0].param[3].value[0].struct[0].member
                    if member.name[0] == "title" then data.title = member.value[0].string[0]
                    if member.name[0] == "description" then data.description = member.value[0].string[0]
                    if member.name[0] == "categories"
                        data.categories.push x.data[0].value[0].string[0] for x in member.value[0].array
                    if member.name[0] == "mt_keywords"
                        data.tags.push x.data[0].value[0].string[0] for x in member.value[0].array
                    if member.name[0] == "post_status" then data.publish = member.value[0].string[0] == "publish"
                if data.login == config.wpLogin and data.password == config.wpPassword
                    for name, hook of hooks
                        if name in data.tags
                            success = success and hook.process data, config
                else
                    success = false
            if not success
                res.status(500)
                content = """
<?xml version="1.0"?>
<methodResponse><fault><value><struct><member><name>faultCode</name><value><int>500</int></value></member><member><name>faultString</name><value>Request was not successful.</value></member></struct></value></fault></methodResponse>
"""
            if content == null then content = """
<?xml version="1.0"?>
<methodResponse><params><param><value></value></param></params></methodResponse>
"""
            res.setHeader "Connection", "close"
            res.setHeader "Content-Length", content.length
            res.setHeader "Content-Type", "text/xml"
            res.send content
