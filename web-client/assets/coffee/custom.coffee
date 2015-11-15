(($)->

  ##
  ## User defined functions.
  ##
  fn = (()->
    {
      getOnlineUsers = ()->
        socket.send JSON.stringify {
          type: 'online-users'
        }
    }
  )()

  $ ()->
    host = window.document.location.host.replace /:.*/, ''
    socket = new WebSocket 'ws://' + host + ':8080'

    ##
    ## Socket events.
    ##
    socket.onmessage = (event)->
      data = JSON.parse event.data
      if data.type is 'join-error'
        alert data.message
      else if data.type is 'join-success'
        alias = data.name
        fn.getOnlineUsers()
        $('.pick-alias').hide()
        $('.chat-window').show()


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