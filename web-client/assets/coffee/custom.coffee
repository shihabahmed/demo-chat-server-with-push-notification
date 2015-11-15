(($)->
  ##
  ## Connecting to the chat server.
  ##
  host = window.document.location.host.replace /:.*/, ''
  socket = new WebSocket 'ws://' + host + ':8080'
  alias = ''

  ##
  ## Socket events.
  ##
  socket.onmessage = (event)->
    data = JSON.parse event.data
    if data.type is 'join-error'
      alert data.message
    else if data.type is 'join-success'
      alias = data.name
      fn.getOnlineUsers(socket)
      $('.pick-alias').hide()
      $('.chat-window').show()
    else if data.type is 'online-users'
      users = data.message.split ','
      usersList.html ''
      for user in users
        usersList.append '<option value="' + user + '">' + user + '</option>' if user != alias
    else if data.type is 'text'
      fn.addMessage content, data.message, data.from

  ##
  ## User defined functions.
  ##
  fn = (()->
    {
      getOnlineUsers: (socket)->
        socket.send JSON.stringify {
          type: 'online-users'
        }

      showMessage: (messageArea, message, from)->
        messageArea.prepend '<p><strong>' + from + ' <em>[' + new Date().toLocaleString() + ']</em>: </strong> <span>' + message + '</span></p>'
    }
  )()

  $ ()->
    btnJoin = $ '.join'
    txtAlias = $ '.alias'
    usersList = $ '.user'
    messageBox = $ '.message'
    btnSendMessage = $ '.send-message'
    content = $ '.content'

    ##
    ## Binding events to html elements
    ##
    btnJoin.click ()->
      socket.send JSON.stringify {
        type: 'alias'
        name: txtAlias.val()
      }

    btnSendMessage.click ()->
      socket.send JSON.stringify {
        type: 'text'
        to: usersList.val()
        from: alias
        message: messageBox.val()
      }
      messageBox.focus().val ''

) jQuery