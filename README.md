
A server to allow multiple insteon apps to share a PLM
======================================================

This is a standalone server, aka hub, that provides http access to the module [home-controller](https://github.com/automategreen/home-controller) which provides high-level access to the insteon network through a hub or a PLM on a serial port. `insteon-hub` only supports using [home-controller](https://github.com/automategreen/home-controller) with a serial port since it is itself a hub.

`insteon-hub` allows multiple home control apps to access the insteon network simultaneously.  For example I have an HVAC app and a media center app both talking to insteon using `insteon-hub`.

The home control app can be in a desktop using Node or in a web page using Ajax to issue the http requests.  Note that this means even a mobile device can send commands directly to your insteon network.

### Usage
  
Use `npm install insteon-hub` to install in the folder of your choice.  You will then find a folder called `node_modules` in that folder.  Use `cd node_modules/insteon-hub` to enter the `insteon-hub` project folder.

To start the server use `node ./lib/main <serial device> <network port>`. On a mac or linux it will look like `node ./lib/main /dev/ttyUSB0 1342` or `node .\lib\main com1 3000` on windows.

### HTTP Requests (URL Commands)

As of this version you can only send commands to the insteon network.  In the near future you will be able to use a websocket to receive real-time events.

Each http request causes [home-controller](https://github.com/automategreen/home-controller) to execute one function call.  The call can be a method on the main `Insteon` (plm) object or a device instance depending on whether the first part of the path is "plm" or not.

You must learn the [home-controller](https://github.com/automategreen/home-controller) function calls before you can use `insteon-hub`.

The URL format for a http request (function call) to the plm object is ...

```
http://<your-ip-number>:<your-port-number>/plm/<command>/arg1/arg2/...

# examples
http://192.168.1.100:3000/plm/info
http://192.168.1.100:3000/plm/info/03A280
```

Note that the above examples won't give useful responses unless you add `?async=1` to the end.  See the *Responses* section below.

Commands to devices have this format.  Note the similarity ...
```
http://<your-ip-number>:<your-port-number>/<device>/<command>/<device id>/arg1/arg2/...

#examples
http://192.168.1.100:3000/io/on/67E2F1
http://192.168.1.100:3000/light/turnOn/42FE92/50/slow
```

All arguments are strings and hex values must have all digits.  So an arg of `4` would not work but `04` would.  The case of devices and commands does matter but the case of hex numbers does not.

### Reponses

The response is always in json format.  If you don't add `?async=1` to the end of the request URL, then the response will be the return value of the call to the [home-controller](https://github.com/automategreen/home-controller) function.  If you do add `?async=1` then the response will be the value of the callback from that function.

Not all functions have callbacks.  So be careful to only use async mode on ones that do, like the plm::info functions in the example above.  Read the [home-controller](https://github.com/automategreen/home-controller) documentation for details.

### Status

`insteon-hub` is in alpha status.  It has only been tested so far with `plm` and `io` devices.  It will be tested with `light` devices soon.

### License

`insteon-hub` is copyright Mark Hahn using the MIT license.

