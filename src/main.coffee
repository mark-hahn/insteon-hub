
url  = require 'url'
http = require "http"
dbg  = require('debug') 'insteon-hub'
Insteon = require("home-controller").Insteon
plm = new Insteon()

[serialDevice, port] = process.argv[2..]
serialDevice ?= '/dev/insteon' # e.g. com1 or /dev/ttyUSB0
port ?= 3000

dbg.log = console.log.bind console

server = http.createServer (req, res) ->
  urlParts = url.parse req.url, true
  [__, device, cmd, data...] = urlParts.pathname.split '/'
  async = urlParts.query.async
  if device isnt 'favicon.ico'
    dbg 'req:', JSON.stringify {device, cmd, data, async}
  
  try
    deviceInstance = (if device is 'plm' then plm \
                      else id = data.shift(); plm[device](id, plm))
    syncResp = deviceInstance[cmd].call deviceInstance, data..., (err, asyncResp) ->
      dbg 'async cb', {async, err, asyncResp}
      if async
        if err
          msg = 'async response error: ' + req.url + ', ' + JSON.stringify err
          dbg msg
          res.writeHead 404, 'Content-Type': 'text/text'
          res.end msg
        else  
          res.writeHead 200, 'Content-Type': 'text/json'
          res.end JSON.stringify asyncResp ? error: 'No async response.'
    if not async
      res.writeHead 200, 'Content-Type': 'text/json'
      res.end JSON.stringify syncResp ? error: 'No sync response.'
  catch e  
    dbg 'exception', e
    msg = 'invalid request or no plm response: ' + req.url
    dbg msg
    res.writeHead 404, 'Content-Type': 'text/text'
    res.end msg

plm.serial serialDevice, ->
  dbg 'plm connected to ' + serialDevice
  dbg 'server listening on port ' + port
  server.listen +port
