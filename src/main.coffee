
url  = require 'url'
http = require "http"
Insteon = require("home-controller").Insteon
plm = new Insteon()

server = http.createServer (req, res) ->
  urlParts = url.parse req.url, true
  [__, device, cmd, data...] = urlParts.pathname.split '/'
  async = urlParts.query.async
  if device isnt 'favicon.ico'
    console.log 'req:', JSON.stringify {device, cmd, data, async}
  
  try
    deviceInstance = (if device is 'plm' then plm \
                      else id = data.shift(); plm[device](id, plm))
    console.log cmd, data
    syncResp = deviceInstance[cmd].call deviceInstance, data..., (err, asyncResp) ->
      console.log 'async cb', {async, err, asyncResp}
      if async
        if err
          msg = 'async response error: ' + req.url + ', ' + JSON.stringify err
          console.log msg
          res.writeHead 404, 'Content-Type': 'text/text'
          res.end msg
        else  
          res.writeHead 200, 'Content-Type': 'text/json'
          res.end JSON.stringify asyncResp ? error: 'No async response.'
    if not async
      res.writeHead 200, 'Content-Type': 'text/json'
      res.end JSON.stringify syncResp ? error: 'No sync response.'
  catch e  
    console.log 'exception', e
    msg = 'invalid request or no plm response: ' + req.url
    console.log msg
    res.writeHead 404, 'Content-Type': 'text/text'
    res.end msg

plm.serial '/dev/insteon', ->
  console.log 'plm connected listening on 1342'
  server.listen 1342
