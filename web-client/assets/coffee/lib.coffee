
###
# Exported Lib Starts Here
###

window.__app = {} unless window.__app

window.__app.lib = {}

###
  Core Utils
###

window.__app.lib.utils = {

  hasFocus: ->
    document.hasFocus()

  delay: (ms, fn)->
    setTimeout fn, ms

  query: (context, selector)-> context.querySelector selector

  queryAll: (context, selector)-> context.querySelectorAll selector

  cloneObjects: (obj)->
    return obj  if obj is null or typeof (obj) isnt "object"
    temp = new obj.constructor()
    for key of obj
      temp[key] = clone(obj[key])
    return temp

  replaceAllInString: (str0, str1, str2, ignore)->
    str0.replace new RegExp(str1.replace(/([\/\,\!\\\^\$\{\}\[\]\(\)\.\*\+\?\|\<\>\-\&])/g, "\\$&"), ((if ignore then "gi" else "g"))), (if (typeof (str2) is "string") then str2.replace(/\$/g, "$$$$") else str2)

  generateRandomKey: (len = 16)->
    alph = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'.split ''
    return (alph[Math.floor(Math.random()*alph.length)%alph.length-1] for i in [0...len]).join ''

  callWhenReady: (fn)->
    window.addEventListener 'load', fn  
    # window.addEventListener 'DOMContentLoaded', fn

  initServiceWorker: ->
    if 'serviceWorker' of navigator
      navigator.serviceWorker.register('/service-worker.coffee.js')
        .then (registration)->
          registration.pushManager.subscribe { userVisibleOnly: true }
            .then (pushSubscription)->
              console.log pushSubscription
            , (err)-> console.log err
        .catch (err)->
          console.log err
    else
      console.log 'Service Worker is not available.'

  showNotification: (title, message)->
    if 'serviceWorker' of navigator
      navigator.serviceWorker.getRegistration().then (registration)->
        notificationOption = {
          body: message
          tag: 'new-notification'
          icon: '../favicon.ico'
        }
        if registration.showNotification
          registration.showNotification title, notificationOption
        else
          new Notification title, notificationOption
    else
      console.log 'Service worker is not available.'

  doCrossDomainRequest: ->
    # TODO
    # https://plainjs.com/javascript/ajax/send-ajax-get-and-post-requests-47/
    # https://plainjs.com/javascript/ajax/making-cors-ajax-get-requests-54/
    # http://stackoverflow.com/questions/5584923/a-cors-post-request-works-from-plain-javascript-but-why-not-with-jquery

  getData: (serverEvent)->
    JSON.parse serverEvent.data

}


WebSocket::sendData = (obj)->
  @.send JSON.stringify obj

Array::diff = (arr)->
  @.filter (item)-> arr.indexOf(item) < 0
