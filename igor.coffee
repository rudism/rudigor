express = require "express"
path = require "path"
fs = require "fs"

#logfile = fs.createWriteStream "./log.txt", {flags: "w"}

app = express()
app.configure ->
    app.set "port", 4242
    app.set "views", __dirname + "/views"
    app.set "view engine", "jade"
    app.use express.favicon(path.join(__dirname, "public/favicon.ico"))
    #app.use express.logger({stream: logfile})
    app.use (req, res, next) ->
        data = ""
        req.setEncoding("utf8")
        req.on "data", (chunk) ->
            data += chunk
        req.on "end", ->
            req.rawBody = data
            next()
    app.use express.json()
    app.use express.urlencoded()
    app.use express.methodOverride()
    app.use app.router
    app.use require("stylus").middleware(__dirname, "public")
    app.use express.static(path.join(__dirname, "public"))
    app.use express.errorHandler({showStack: true, showMessage: true, dumpExceptions: true})

require("./tasks/ifttt.coffee")(app)
require("./tasks/xmpp-notifier.coffee")(app)

app.get '/', (req, res) ->
    res.render 'index',
        title: 'RudiGor'

app.listen app.get("port"), ->
    console.log "RudIgor listening on port " + app.get("port")
