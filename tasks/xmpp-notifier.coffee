xmpp = require 'node-xmpp-client'
config = require "./config/xmpp.config.json"
ltx = require 'ltx'
redis = require 'redis'
express = require 'express'
Promise = require('es6-promise').Promise

rclient = redis.createClient()
auth = express.basicAuth config.authUser, config.authPassword

connectClient = (jid, clientcfg) ->
    xmppconfig =
        jid: jid
        password: clientcfg.password
    if clientcfg.host?
        xmppconfig.host = clientcfg.host
    client = new xmpp.Client xmppconfig
    client._igorJid = jid
    client._igorConfig = clientcfg
    client.on 'online', () ->
        rclient.set "xmpp-status-#{this._igorJid}", "Online"
        myconfig = this._igorConfig
        this.send (new ltx.Element 'presence', {}
            .c('show').t('chat').up()
            .c('status').t(myconfig.status).up()
            .c('priority').t(myconfig.priority))
        console.log "INFO #{this.jid}: Online"
    client.on 'error', (e) ->
        rclient.set "xmpp-status-#{this._igorJid}", "Error: #{e}"
        console.error "ERROR #{this.jid}: #{e}"
        jid = this._igorJid
        clientcfg = this._igorConfig
        setTimeout () ->
            connectClient jid, clientcfg
        , 300000

for jid, clientcfg of config.clients
    rclient.set "xmpp-status-#{jid}", "Connecting"
    console.log "INFO #{jid}: Connecting"
    connectClient jid, clientcfg

getFromRedis = (key) ->
    new Promise (resolve, reject) ->
        rclient.get key, (err, reply) ->
            if err?
                reject err
            else
                resolve
                    key: key
                    value: reply

module.exports = (app) ->
    app.get "/xmpp", auth, (req, res) ->
        promises = []
        for jid, clientcfg of config.clients
            promises.push getFromRedis "xmpp-status-#{jid}"
        Promise.all(promises).then (replies) ->
            statuses = []
            for reply in replies
                statuses.push
                    jid: reply.key
                    status: reply.value
            res.render 'xmpp',
                title: 'XMPP Task'
                statuses: statuses
