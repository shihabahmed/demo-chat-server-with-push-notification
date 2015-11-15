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
    data = JSON.parse obj
    if data.type is 'alias'
      if users[data.name]
        client.send JSON.stringify {
          type: 'join-error'
          message: "#{data.alias} is not available!"
        }
      else
        users[data.name] = client
        users[data.name].send JSON.stringify {
          type: 'join-success'
          name: data.name
        }
        wss.broadcast Object.keys(users).join(','), 'online-users'
    # else if data.type is 'online-users'



  client.on 'close', ()->
    # do something when client leaves


## Sends message to all the clients currently connected.
wss.broadcast = (data, type)->
  wss.clients.forEach each = (client)->
    client.send JSON.stringify {
      type: type
      message: data
    }
