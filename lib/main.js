// Generated by CoffeeScript 1.9.3
(function() {
  var Insteon, dbg, http, plm, port, ref, serialDevice, server, url,
    slice = [].slice;

  url = require('url');

  http = require("http");

  dbg = require('debug')('insteon-hub');

  Insteon = require("home-controller").Insteon;

  plm = new Insteon();

  ref = process.argv.slice(2), serialDevice = ref[0], port = ref[1];

  if (serialDevice == null) {
    serialDevice = '/dev/insteon';
  }

  if (port == null) {
    port = 3000;
  }

  dbg.log = console.log.bind(console);

  server = http.createServer(function(req, res) {
    var __, async, cmd, data, device, deviceInstance, e, id, msg, ref1, ref2, syncResp, urlParts;
    urlParts = url.parse(req.url, true);
    ref1 = urlParts.pathname.split('/'), __ = ref1[0], device = ref1[1], cmd = ref1[2], data = 4 <= ref1.length ? slice.call(ref1, 3) : [];
    async = urlParts.query.async;
    if (device !== 'favicon.ico') {
      dbg('req:', JSON.stringify({
        device: device,
        cmd: cmd,
        data: data,
        async: async
      }));
    }
    try {
      deviceInstance = (device === 'plm' ? plm : (id = data.shift(), plm[device](id, plm)));
      syncResp = (ref2 = deviceInstance[cmd]).call.apply(ref2, [deviceInstance].concat(slice.call(data), [function(err, asyncResp) {
        var msg;
        dbg('async cb', {
          async: async,
          err: err,
          asyncResp: asyncResp
        });
        if (async) {
          if (err) {
            msg = 'async response error: ' + req.url + ', ' + JSON.stringify(err);
            dbg(msg);
            res.writeHead(404, {
              'Content-Type': 'text/text'
            });
            return res.end(msg);
          } else {
            res.writeHead(200, {
              'Content-Type': 'text/json'
            });
            return res.end(JSON.stringify(asyncResp != null ? asyncResp : {
              error: 'No async response.'
            }));
          }
        }
      }]));
      if (!async) {
        res.writeHead(200, {
          'Content-Type': 'text/json'
        });
        return res.end(JSON.stringify(syncResp != null ? syncResp : {
          error: 'No sync response.'
        }));
      }
    } catch (_error) {
      e = _error;
      dbg('exception', e);
      msg = 'invalid request or no plm response: ' + req.url;
      dbg(msg);
      res.writeHead(404, {
        'Content-Type': 'text/text'
      });
      return res.end(msg);
    }
  });

  plm.serial(serialDevice, function() {
    dbg('plm connected to ' + serialDevice);
    dbg('server listening on port ' + port);
    return server.listen(+port);
  });

}).call(this);
