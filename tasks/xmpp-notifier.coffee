xmpp = require 'node-xmpp-client'
config = require "./config/xmpp.config.json"
pushovercfg = require './config/pushover.config.json'
Pushover = require 'node-pushover-client'
pusher = new Pushover pushovercfg
ltx = require 'ltx'
redis = require 'redis'
express = require 'express'
Promise = require('es6-promise').Promise
basicAuth = require 'http-auth'

rclient = redis.createClient()
auth = basicAuth.basic {realm: 'Private'}, (u, p, callback) ->
    callback (u == config.authUser and p == config.authPassword)


getFromRedis = (key) ->
    new Promise (resolve, reject) ->
        rclient.get key, (err, reply) ->
            if err?
                reject err
            else
                resolve
                    key: key
                    value: reply

processMessage = (from, message) ->
    pusher.send
        title: from
        message: message
    .then (res) ->
        if res.status == 0
            console.log "ERROR Pushover notification failed: #{res.errors}"

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
        this.send (new ltx.Element 'iq', {from: this.jid, type: 'get', id: 'roster_0'}
            .c('query', xmlns: 'jabber:iq:roster'))
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
    client.on 'stanza', (stanza) ->
        if stanza.is('iq') and stanza.attrs.type == 'result' and stanza.attrs.id == 'roster_0'
            query = stanza.getChild 'query', 'jabber:iq:roster'
            for item in query.getChildren 'item'
                jid = item.attrs.jid
                name = item.attrs.name.replace '"', "'"
                rclient.set "xmpp-roster-#{jid}", name
        else if stanza.is('message') and stanza.type == 'chat'
            from = stanza.attrs.from
            if from.indexOf('/') >= 0
                from = from.substring 0, from.indexOf '/'
            message = stanza.getChildText 'body'
            if from? and message?
                getFromRedis("xmpp-roster-#{from}").then (fromname) ->
                    processMessage (if fromname.value? then fromname.value else from), message
                , () ->
                    processMessage from, message

for jid, clientcfg of config.clients
    rclient.set "xmpp-status-#{jid}", "Connecting"
    console.log "INFO #{jid}: Connecting"
    connectClient jid, clientcfg

module.exports = (app) ->
    app.get "/xmpp", basicAuth.connect(auth), (req, res) ->
        promises = []
        for jid, clientcfg of config.clients
            promises.push getFromRedis "xmpp-status-#{jid}"
        Promise.all(promises).then (replies) ->
            statuses = []
            for reply in replies
                statuses.push
                    jid: reply.key.substring 12
                    status: reply.value
            res.render 'xmpp',
                title: 'XMPP Task'
                statuses: statuses
