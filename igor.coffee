express = require "express"
path = require "path"
fs = require "fs"
getRawBody = require "raw-body"
favicon = require "serve-favicon"
bodyParser = require "body-parser"
methodOverride = require "method-override"
serveStatic = require "serve-static"
errorHandler = require "errorhandler"

app = express()

app.set "port", 4242
app.set "views", __dirname + "/views"
app.set "view engine", "jade"
app.use favicon path.join __dirname, "public/favicon.ico"
app.use (req, res, next) ->
    if req.header['content-type'] == 'application/xml'
        getRawBody req,
            length: req.headers['content-length']
            limit: '1mb'
            encoding: 'utf8'
        , (err, rawBody) ->
            if err?
                return next err
            req.rawBody = rawBody
            next()
    else
        next()
app.use bodyParser()
app.use methodOverride()
app.use require("stylus").middleware __dirname, "public"
app.use serveStatic path.join __dirname, "public"
app.use errorHandler({showStack: true, showMessage: true, dumpExceptions: true})

require("./tasks/ifttt.coffee")(app)
require("./tasks/draftin.coffee")(app)

app.get '/', (req, res) ->
    res.render 'index',
        title: 'RudiGor'

app.listen app.get("port"), ->
    console.log "RudIgor listening on port " + app.get("port")
