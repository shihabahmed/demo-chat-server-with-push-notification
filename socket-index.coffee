http = require 'http'

server = http.createServer()

server.listen 8080, ()->
  console.log 'WebSocket opened on port 8080'


WebSocketServer = require('ws').Server
wss = new WebSocketServer { server: server }
users = {}

wss.on 'connection', (client)->
  client.send JSON.stringify {
    message: 'Welcome...'
  }

  client.on 'message', (obj)->
    # do something when message arrives

  client.on 'close', ()->
    # do something when client leaves
