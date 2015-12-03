
fslib = require 'fs'

pathlib = require 'path'

httplib = require 'http'

httpslib = require 'https'

urllib = require 'url'

opt = null

directoryDigest = null

LOG_LEVEL = {
  'log'
  'alert'
  'info'
  'warning'
  'error'
}

writeStdout = (level, args...)->
  console.log.apply console, args

## TODO: loads of type checking
validateOptions = (opt)->

  unless opt and typeof opt is 'object'
    throw new Error "Expected opt to be a non null <object>"

  unless 'name' of opt
    opt.name = 'untitled-server'

  if 'http' of opt or 'https' of opt
    unless 'source' of opt
      throw new Error "Missing opt.source. Can not create an http/https server without a directory to serve."

  if 'source' of opt
    unless 'dirList' of opt.source
      throw new Error "Missing opt.source.dirList"
    if opt.source.dirList.length is 0
      throw new Error "opt.source.dirList can not be empty"

  ## TODO - validate other options

  return opt



buildDirectoryDigest = (dirList)->

  directoryDigest = {}

  buildDirectoryDigestRecursive = (dir, basedir)->

    list = fslib.readdirSync dir
    for basename in list
      qualifiedPath = pathlib.join dir, basename

      stats = fslib.lstatSync qualifiedPath
      if not stats.isSymbolicLink() and stats.isDirectory()
        buildDirectoryDigestRecursive qualifiedPath, basedir
      else
        ## TODO: exclusion filtering
        if opt.source.verify
          fslib.accessSync qualifiedPath, fslib.R_OK
        stats.qualifiedPath = qualifiedPath
        pathname = '\\' + pathlib.relative basedir, qualifiedPath
        directoryDigest[pathname] = stats

  reverseDirectoryList = ((_ for _ in dirList).reverse())
  for dir in reverseDirectoryList
    buildDirectoryDigestRecursive dir, dir

  return directoryDigest

inferMimeOfDigestedFiles = ->
  unrecognizedExtList = []
  for pathname, stats of directoryDigest
    qualifiedPath = stats.qualifiedPath
    ext = pathlib.extname qualifiedPath
    if ext of opt.mime.map
      stats.mime = opt.mime.map[ext]
    else
      stats.mime = opt.mime.map.default
      unrecognizedExtList.push ext unless ext in unrecognizedExtList
  if unrecognizedExtList.length > 0
    writeStdout LOG_LEVEL.warning, 'mime for these extensions could not be infered', unrecognizedExtList

inferEncodingOfDigestedFiles = ->
  
  for pathname, stats of directoryDigest
    qualifiedPath = stats.qualifiedPath
    ## TODO rule matching
    stats.encoding = opt.encoding.default

getFileAsStream = (pathname, cbfn)->
  stats = directoryDigest[pathname]
  stream = fslib.createReadStream stats.qualifiedPath
  return cbfn null, stream


httpHandler = (request, response) ->

  url = urllib.parse request.url

  if '/' is url.pathname.charAt (url.pathname.length-1)
    if opt.remapUrl and opt.remapUrl.slashEnding and opt.remapUrl.slashEnding.append
      newPathname = url.pathname + opt.remapUrl.slashEnding.append
      url.path = url.path.replace url.pathname, newPathname
      url.href = url.href.replace url.pathname, newPathname
      url.pathname = newPathname

  if url.pathname is '' or url.pathname is '/'
    url.pathname = '/index.copoly'

  url.pathname = url.pathname.replace(new RegExp('/', 'g'), '\\')
  unless url.pathname of directoryDigest
    if opt.errorHandling and opt.errorHandling['404'].customResponse
      ## TODO
    else
      response.writeHead 404, 'Content-Type': 'text/plain'
      response.end "The requested URL \"#{url.href}\" can not be resolved to a content"
  else
    getFileAsStream url.pathname, (err, stream)->
      if err
        throw err
      stats = directoryDigest[url.pathname]
      
      response.writeHead 200, 'Content-Type': stats.mime
      stream.pipe response
  return

createHttpsServer = ->

  ca = []
  chain = fslib.readFileSync opt.https.ca, 'utf8'
  chain = chain.split '\n'
  cert = []
  for line in chain when line.length isnt 0
    cert.push line
    if line.match /-END CERTIFICATE-/
      ca.push cert.join "\n"
      cert = []


  hskey = fslib.readFileSync opt.https.pkey
  hscert = fslib.readFileSync opt.https.cert
  options = 
    ca: ca
    key: hskey
    cert: hscert
  sServer = httpslib.createServer options, httpHandler
  writeStdout LOG_LEVEL.log, 'https server created'
  if opt.https.hostname is null
    sServer.listen opt.https.port
    writeStdout LOG_LEVEL.log, "https server listen to port #{opt.https.port} for any hostname."
    writeStdout LOG_LEVEL.log, "can be accessed using https://127.0.0.1:#{opt.https.port}/"
  else
    sServer.listen opt.https.port, opt.http.hostname
    writeStdout LOG_LEVEL.log, "https server listen to port #{opt.https.port} for any #{opt.https.hostname}."
    writeStdout LOG_LEVEL.log, "can be accessed using #{opt.https.hostname}:#{opt.https.port}/"

createHttpServer = ->

  server = httplib.createServer httpHandler
  writeStdout LOG_LEVEL.log, 'http server created'

  if opt.http.hostname is null
    server.listen opt.http.port
    writeStdout LOG_LEVEL.log, "http server listen to port #{opt.http.port} for any hostname."
    writeStdout LOG_LEVEL.log, "can be accessed using http://127.0.0.1:#{opt.http.port}/"
  else
    server.listen opt.http.port, opt.http.hostname
    writeStdout LOG_LEVEL.log, "http server listen to port #{opt.http.port} for any #{opt.http.hostname}."
    writeStdout LOG_LEVEL.log, "can be accessed using #{opt.http.hostname}:#{opt.http.port}/"


@createServer = (_opt)->
  
  opt = validateOptions _opt

  writeStdout LOG_LEVEL.log, 'options accepted'

  if 'source' of opt

    buildDirectoryDigest opt.source.dirList

    writeStdout LOG_LEVEL.log, 'directory digest created. Digest size is', (2*(JSON.stringify directoryDigest).length), 'bytes approximately'

    inferMimeOfDigestedFiles()

    inferEncodingOfDigestedFiles()

    writeStdout LOG_LEVEL.log, 'directory digest updated with mime and encoding info. Digest size is', (2*(JSON.stringify directoryDigest).length), 'bytes approximately'

  if 'http' of opt and opt.http.enabled

    createHttpServer()

  if 'https' of opt and opt.https.enabled

    createHttpsServer()

    

###
  @run
###

this.createServer {
  http:
    hostname: 'localhost'
    port: 8844
    enabled: true
  source:
    dirList: [
      './web-client'
    ]
  mime:
    map:
      '.coffee': 'text/coffeescript'
      '.stylus': 'text/css'
      '.ico': 'image/ico'
      '.copoly': 'text/copoly'
      '.json': 'text/json'
      '.js': 'text/javascript'
  encoding:
    default: {}
}
