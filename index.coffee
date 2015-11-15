ws = require './user_modules/websocket'

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

{CopolymerCompiler} = require 'en-copolymer'

{CoffeescriptCompiler, CoffeescriptTagProcessor} = require 'en-coffee'

{StylusTagProcessor, StylusCompiler} = require 'en-stylus'

###
  @options
###

APP_NAME = 'DemoChatClientContentServer'

FORCE_VIRTUAL_MODE = true

PREFER_VIRTUAL_MODE = true

if FORCE_VIRTUAL_MODE

  __IS_IN_VIRTUAL_MODE = true

else if (require 'os').platform() in ['darwin', 'linux']

  __IS_IN_VIRTUAL_MODE = PREFER_VIRTUAL_MODE

else

  __IS_IN_VIRTUAL_MODE = false

SOURCE_DIR = './web-client'

if __IS_IN_VIRTUAL_MODE

  CLIENT_DIR = SOURCE_DIR

else

  CLIENT_DIR = './web-client-volatile'

WATCH_DEPTH = 12

ANALYTICS_ENABLED = false

VERBOSE_MODE = false

ANALYTICS_DELAY_THRESHHOLD = 5000

###
  @class Program
###

class Program

  @Start: ()->

    ## The http/https server
    server = new WebServer {port: 8844}

    ## UrlParser plugin
    (new UrlParser).linkTo server

    ## BodyParser plugin
    (new BodyParser).linkTo server
    
    ## FileProvider
    if __IS_IN_VIRTUAL_MODE
      ## reduces disk i/o a lot
      fileProvider = new CachedFileProvider {rootDir: CLIENT_DIR, depth: WATCH_DEPTH}
    else
      fileProvider = new FileProvider {rootDir: CLIENT_DIR, depth: WATCH_DEPTH}

    ## Various watcher for changes in file
    fileWatcherList = [
      new CopolymerCompiler
      new CoffeescriptCompiler
      new StylusCompiler
      new CoffeescriptTagProcessor
      new StylusTagProcessor
    ]
    fileWatcher.linkTo fileProvider for fileWatcher in fileWatcherList

    fileWatcher.verboseMode = VERBOSE_MODE for fileWatcher in fileWatcherList

    ## FileServer is a plugin for WebServer
    fileServer = new FileServer

    ## we are going to handle 404s manually
    fileServer.treat404AsError = false

    fileServer.addEventHandler 'error', (e)->
      console.log 'some err', e

    ## This plugin enables custom urls
    server.addEventHandler 'request', 'late', (e)->
      return e.next() if e.isResponseSent
      return e.next() unless fileProvider
      if not fileProvider.isReady
        console.log 'server is preparing'
        e.respond 500, {'content-type':'text/html'}, "<!doctype html>
        <html><head><meta http-equiv=\"refresh\" content=\"3\"></head><body>
        #{APP_NAME} server has just restarted and preparing to serve your request.
        This page should automatically refresh in 3 seconds. If it takes longer, please refresh manually.</body></html>"
        e.next()
      else
        uri = e.url.pathname
        fileProvider.getResourceInfo uri, (err, stats)=>
          unless err
            throw new Error 'Something is really wrong'
          if (require 'path').extname(uri) is ''
            e.reset()
            e.request.url = e.request.url.replace e.url.pathname, '/index.html'
            e.url.pathname = '/index.html'
            return e.next()
          else
            return e.next()

    ## Finally send a 404 message if content was really not found
    server.addEventHandler 'request', 'late', (e)->
      return e.next() if e.isResponseSent
      e.respond 404, '404 - Content not found'
      e.stopPropagation().next()

    ## for logging purposes
    server.addEventHandler 'start', (e)-> 
      console.log "(content-server)> started on port #{e.origin.port}"

    ## for logging purposes
    server.addEventHandler 'request', (e)->
      return e.next() if e.url.pathname isnt '/'
      console.log "(content-server)> request from #{e.request.socket.remoteAddress}"
      # console.log "#{e.request.url} from #{e.request.socket.remoteAddress}"
      # console.log e.request.headers
      return e.next()

    ## for logging purposes
    server.addEventHandler 'respond', (e)->
      status = e.storedData.originalRequest.response.statusCode
      if status isnt 200
        console.log status, e.storedData.originalRequest.url.pathname

    ## for logging purposes
    fileServer.addEventHandler 'start', =>
      console.log '(file-server)> started'
    
    ## for logging purposes
    fileProvider.addEventHandler 'ready', =>
      console.log '(file-provider)> started'

    ## connect fileServer to server only when fileProvider is ready
    fileProvider.addEventHandler 'ready', =>
      fileServer.setFileProvider fileProvider
      fileServer.linkTo server

    ## start stuff
    fileProvider.start()
    server.start()

    ws.open(8844)

    ## Analytic Code
    if ANALYTICS_ENABLED
      lastAnalyticChangesFound = null
      wasCleared = false
      setInterval =>
        if fileProvider.wasAnalyticUpdated()
          if lastAnalyticChangesFound is null
            lastAnalyticChangesFound = new Date()
          else
            if (new Date).getTime() - lastAnalyticChangesFound.getTime() > ANALYTICS_DELAY_THRESHHOLD
              console.log fileProvider.printAnalyticInformation()
              lastAnalyticChangesFound = null
              wasCleared = false
        else
          if lastAnalyticChangesFound isnt null
            if (new Date).getTime() - lastAnalyticChangesFound.getTime() > ANALYTICS_DELAY_THRESHHOLD
              console.log fileProvider.printAnalyticInformation()
              lastAnalyticChangesFound = null
              wasCleared = false
          else
            unless wasCleared
              console.log '\nWaiting for Analytic changes\n'
            wasCleared = true
      , 100

###
  @run
###

rimraf = (require 'rimraf')
ncp = (require 'ncp').ncp

if __IS_IN_VIRTUAL_MODE
  console.log '(program)> virtual mode enabled. disk I/O will be virtualized.'
  console.log '(program)> start'
  Program.Start()
else
  console.log '(program)> removing leftover temporary directory'
  rimraf CLIENT_DIR, (err)->
    throw err if err

    console.log '(program)> cloning source to temporary directory'
    ncp SOURCE_DIR, CLIENT_DIR, {}, (err)->
      throw err if err

      console.log '(program)> start'
      Program.Start()

return


