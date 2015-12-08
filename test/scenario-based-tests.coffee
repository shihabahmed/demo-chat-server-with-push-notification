
expect = require('chai').expect

io = require 'socket.io-client'

socket = io.connect 'wss://localhost:7443'

describe 'Socket Test', ->
  describe 'Trying to connect', ->
    it 'should be able to connect to the chat server', ->
      socket.on 'connect', (done)->
        done()

  describe 'Sending message', ->
    it 'should be able to send messages', ->
      socket.send 'test message'

      socket.on 'message', (obj)->
        data = JSON.parse obj
        expect(data.message).to.be 'test messages'
