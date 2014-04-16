exports.process = (data, config) ->
    https = require "http"
    options =
        host: "sendtoreader.com"
        path: "/api/send/?username=#{encodeURIComponent config.s2rLogin}&password=#{encodeURIComponent config.s2rPassword}&url=#{encodeURIComponent data.description}&title=#{encodeURIComponent data.title}"
    https.get options, (res) ->
    return true
