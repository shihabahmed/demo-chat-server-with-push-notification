importScripts 'serviceworker-cache-polyfill.js'

CACHE_NAME = 'demo-chat-application'
URLS = [
  '/'
  '/index.html'
  '/assets/stylus/dom-root.stylus.css'
  '/assets/stylus/common.stylus.css'
  '/assets/stylus/custom.stylus.css'
  '/assets/coffee/lib.coffee.js'
  '/assets/coffee/init.coffee.js'
  '/assets/coffee/custom.coffee.js'
]

this.addEventListener 'install', (event)->
  this.skipWaiting()
  event.waitUntil caches.open(CACHE_NAME).then (cache)->
    cache.addAll URLS

this.addEventListener 'fetch', (event)->
  event.respondWith caches.match(event.request).then (response)->
    if response
      return response