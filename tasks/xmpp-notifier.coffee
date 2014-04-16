xmpp = require 'node-xmpp-client'
config = require "./config/xmpp.config.json"

clients = []

for clientcfg in config.clients
    client = new xmpp.Client clientcfg
    client.on 'online', () ->
        console.log "#{this.jid}: Online"
    client.on 'error', (e) ->
        console.error "#{this.jid}: #{e}"
    clients.push client

module.exports = (app) ->
    app.get "/xmpp", (req, res) ->
        res.send "nothing yet"
