(($)->
  $ ()->

    ##
    ## User defined functions.
    ##
    fn = (()->
      {
        getOnlineUsers: (socket)->
          socket.sendData {
            type: 'online-users'
          }

        showMessage: (messageArea, message, from)->
          messageArea.prepend "<p class=#{from}><strong>#{from} <em>[#{new Date().toLocaleString()}]</em>: </strong> <span>#{message}</span></p>"
      }
    )()

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
      data = lib.utils.getData event

      if data.type is 'join-error'
        alert data.message

      else if data.type is 'join-success'
        alias = data.name
        fn.getOnlineUsers(socket)
        $('.pick-alias').hide()
        $('.chat-window').show()

      else if data.type is 'online-users'
        onlineUsers = userSelect.data 'users'
        users = data.message.split ','
        userSelect.html ''
        userSelect.data 'users', users
        for user in users
          userSelect.append "<option value='#{user}'>#{user}</option>" if user != alias

        if onlineUsers != undefined and onlineUsers != null and onlineUsers.length > 0
          if users.length > onlineUsers.length
            user = users.diff onlineUsers
            lib.utils.showNotification 'User Joined', "#{user} just joined the chat room."
          else
            user = onlineUsers.diff users
            lib.utils.showNotification 'User Left', "#{user} just left the chat room."

      else if data.type is 'text'
        console.log data
        fn.showMessage content, data.message, data.from



    btnJoin = $ '.join'
    txtAlias = $ '.alias'
    userSelect = $ '.user'
    messageBox = $ '.message'
    btnSendMessage = $ '.send-message'
    content = $ '.content'

    ##
    ## Binding events to html elements
    ##
    btnJoin.click ()->
      socket.sendData {
        type: 'alias'
        name: txtAlias.val()
      }

    txtAlias.keydown (e)->
      btnJoin.click() if e.keyCode is 13

    btnSendMessage.click ()->
      fn.showMessage content, messageBox.val(), 'me'

      socket.sendData {
        type: 'text'
        to: userSelect.val()
        from: alias
        message: messageBox.val()
      }
      messageBox.focus().val ''
    
    messageBox.keydown (e)->
      btnSendMessage.click() if e.keyCode is 13

) jQuery