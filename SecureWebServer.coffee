{
  Event
  EventEmitter
  web: {
    WebServer
    extra: {
      UrlParser
      BodyParser
    }
  }
  file: {
    FileProvider
    CachedFileProvider
  }
  fileServer: {
    FileServer
  }
} = require 'evolvenode'

certificate = require './ssl-certificate.coffee'

###
  @class SecureWebServer
###

module.exports = class SecureWebServer extends WebServer
  constructor: ({@port, @host, @ssl} = {}) ->
    super
    @ssl or= null

  start: ()->
    options = certificate.generateCertificate @ssl

    @nodeServer = (require 'https').createServer options, @_handleNodeServerRequest
    if @host
      @nodeServer.listen @port, @host, =>
        @emit 'start'
    else
      @nodeServer.listen @port, =>
        @emit 'start'
