
# shortcuts
window.app = __app
window.lib = app.lib

# loaded
lib.utils.callWhenReady ->

  console.log 'App is running'

  host = window.document.location.host.replace /:.*/, ''
  socket = new WebSocket 'ws://' + host + ':8844'

  ##
  ## Socket events.
  ##
  socket.onmessage = (event)->
    data = JSON.parse event.data
    console.log data.message

