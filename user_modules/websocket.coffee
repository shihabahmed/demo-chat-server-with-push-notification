exports.open = (port)->
  WebSocketServer = require('ws').Server
  wss = new WebSocketServer { port: port }
  users = {}

  wss.on 'connection', (client)->
    client.send {
      message: 'Welcome...'
    }

    client.on 'message', (event)->
      # do something when message arrives

    client.on 'close', ()->
      # do something when message arrives
