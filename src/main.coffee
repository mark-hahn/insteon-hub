
express = require("express")
Insteon = require("home-controller").Insteon

plm = new Insteon()

app = express()
app.get "/light/:id/on", (req, res) ->
  id = req.params.id
  plm.light(id).turnOn().then (status) ->
    if status.response
      res.send 200
    else
      res.send 404

plm.serial '/dev/insteon', ->
  console.log 'plm connected'
  io = plm.io '28AB42'
  console.log 'io.on', io.off '02'
  
  # plm.info '297ebf', (err, info) ->
  #   console.log 'info', {err, info}
  # app.listen 1342
  