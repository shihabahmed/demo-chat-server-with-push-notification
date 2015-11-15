(($)->
  $ ()->
    host = window.document.location.host.replace /:.*/, ''
    socket = new WebSocket 'ws://' + host + ':8080'

    ##
    ## Socket events.
    ##
    socket.onmessage = (event)->
      data = JSON.parse event.data
      console.log data.message

    btnJoin = $ '.join'
    txtAlias = $ '.alias'
    users = $ '.user'
    messageBox = $ '.message'
    btnSendMessage = $ '.send-message'
    content = $ '.content'

    btnJoin.click ()->
      socket.send JSON.stringify {
        type: 'alias'
        name: txtAlias.val()
      }
) jQuery