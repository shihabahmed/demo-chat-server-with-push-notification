
expect = require('chai').expect

io = require 'socket.io-client'

socketURL = 'wss://localhost:7443'
socketOptions = 
  transports: ['websocket']
  'force new connection': true

socket = {}


describe 'Array', ->
  beforeEach (done) ->
    socket = io.connect socketURL, socketOptions
    socket.on 'connect', ()->
      console.log('connected')

    done()

  describe 'Trying to connect', ->
    it 'should be able to connect to the chat server', ->
      socket.on 'connect', (done)->
        done()

  describe 'Sending message', ->
    it 'should be able to send messages', ->
      socket.send 'test message'

      socket.on 'message', (obj)->
        data = JSON.parse obj
        expect(data.message).to.be.equal 'test messages'
