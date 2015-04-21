
url  = require 'url'
http = require "http"
Insteon = require("home-controller").Insteon
plm = new Insteon()

server = http.createServer (req, res) ->
  [__, id, sync, device, cmd, data] = url.parse(req.url).path.split '/'
  if id is '_' then id = null
  if id isnt 'favicon.ico' then console.log 'req:', JSON.stringify {id, sync, device, cmd, data}
  
  try
    # console.log factory: plm[device].toString()
    # console.log device:  (if (factory = plm[device]) then factory.call(plm,id) else plm).toString()
    # console.log cmd:     (if (factory = plm[device]) then factory.call(plm,id) else plm)[cmd].toString()
    
    deviceInstance = (if (factory = plm[device]) then factory.call(plm, id) else plm)
    syncResp = deviceInstance[cmd].call deviceInstance, data, (err, asyncResp) ->
      if sync is 'async'
        console.log {err, asyncResp}
        if err
          msg = 'async response error: ' + req.url + ', ' + JSON.stringify err
          console.log msg
          res.writeHead 404, 'Content-Type': 'text/text'
          res.end msg
        else 
          res.writeHead 200, 'Content-Type': 'text/json'
          res.end JSON.stringify asyncResp
  catch e  
    console.log 'exception', e
    console.trace()
    sync = null
    msg = 'invalid request or no plm response: ' + req.url
    console.log msg
    res.writeHead 404, 'Content-Type': 'text/text'
    res.end msg
  
  if sync is 'sync'
    res.writeHead 200, 'Content-Type': 'text/json'
    res.end JSON.stringify syncResp

plm.serial '/dev/insteon', ->
  console.log 'plm connected listening on 1342'
  server.listen 1342
