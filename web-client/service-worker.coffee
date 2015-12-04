importScripts 'serviceworker-cache-polyfill.js'

CACHE_NAME = 'demo-chat-application'
URLS = [
  '/'
  '/index.html'
  '/assets/stylus/dom-root.stylus.css'
  '/assets/stylus/common.stylus.css'
  '/assets/stylus/custom.stylus.css'
  '/assets/lib/jquery.min.js'
  '/assets/coffee/lib.coffee.js'
  '/assets/coffee/init.coffee.js'
  '/assets/coffee/custom.coffee.js'
]

this.addEventListener 'install', (event)->
  this.skipWaiting()
  event.waitUntil caches.open(CACHE_NAME).then (cache)->
    cache.addAll URLS

this.addEventListener 'fetch', (event)->
  # Checking cache for the requested resource
  event.respondWith caches.match(event.request).then (response)->
    # Serve resource from cache if available
    if response
      refreshContent event.request, 2000
      return response

    # If requested resource is not available from cache
    # request online for content immediately
    refreshContent event.request, 0


# Update caches with fresh content after a given milliseconds
refreshContent = (request, ms)->
  setTimeout ->
    fetch(request).then (response)->
      caches.open(CACHE_NAME).then (cache)->
        cache.put request, response

    response.clone()
  , ms
