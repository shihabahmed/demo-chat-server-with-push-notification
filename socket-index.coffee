https = require 'https'

ssl = require './ssl-certificate.coffee'

options = ssl.generateCertificate {
  ca: 'certificates/beta_bdemr_xyz.ca-bundle'
  key: 'certificates/beta_bdemr_xyz.key'
  cert: 'certificates/beta_bdemr_xyz.crt'
}

server = https.createServer(options)

server.listen 7443, ()->
  console.log 'WebSocket opened on port 7443'


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
      data.name = data.name.toLowerCase()
      if users[data.name]
        client.send JSON.stringify {
          type: 'join-error'
          message: "#{data.name} is not available!"
        }
      else
        users[data.name] = client
        users[data.name].send JSON.stringify {
          type: 'join-success'
          name: data.name
        }

    else if data.type is 'online-users'
      wss.broadcast Object.keys(users).join(','), 'online-users'

    else
      users[data.to].send JSON.stringify {
        type: data.type
        from: data.from
        message: data.message
      }



  client.on 'close', ()->
    for user in Object.keys(users)
      if users[user] is client
        delete users[user]

    # Broadcast the updated list of online users
    wss.broadcast Object.keys(users).join(','), 'online-users'


## Sends message to all the clients currently connected.
wss.broadcast = (data, type)->
  wss.clients.forEach each = (client)->
    client.send JSON.stringify {
      type: type
      message: data
    }
