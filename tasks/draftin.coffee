config = require "./config/draftin.config.json"
fs = require 'fs'
exec = require('child_process').exec
Promise = require('es6-promise').Promise

writePost = (path, content) ->
    new Promise (resolve, reject) ->
        fs.writeFile path, content, 'utf8', (err) ->
            if err?
                reject err
            else
                resolve()

hexoGenerate = (hexo, path) ->
    new Promise (resolve, reject) ->
        exec hexo + ' generate',
            cwd: path
        , (err, stdout, stderr) ->
            if err?
                reject err
            else
                resolve()

s3sync = (s3cmd, path, bucket) ->
    new Promise (resolve, reject) ->
        exec s3cmd + ' sync ' + path + ' s3://' + bucket + ' --delete-removed',
            cwd: path
        , (err, stdout, stderr) ->
            if err?
                reject err
            else
                resolve()

module.exports = (app) ->
    app.post "/draftin", (req, res) ->
        console.log 'got post from draft'
        body = JSON.parse req.body.payload
        console.log 'parsed post'
        secret = req.query['site']
        content = body.content
        name = body.name
        url = ''
        if config.blogs[secret]?
            rootpath = config.blogs[secret].hexo_dir
            fpath = rootpath + '/source/_posts/' + name + '.md'
            console.log 'writing post file...'
            writePost(fpath, content).then () ->
                console.log 'hexo generating...'
                hexoGenerate(config.hexo, config.blogs[secret].hexo_dir).then () ->
                    console.log 's3 syncing...'
                    s3sync(config.s3cmd, rootpath + '/public/', config.blogs[secret].s3_bucket).then () ->
                        res.set 'location', config.blogs[secret].publish_url.replace '{name}', name
                        res.send()
                    , (err) ->
                        res.send 500, err
                , (err) ->
                    res.send 500, err
            , (err) ->
                res.send 500, err
        else
            res.send 403, 'not found'
