# demo-chat-server-with-push-notification

# The task

It is a simple chat application that utilizes two transports instead of only one. The authentication is not a concern for you right now. Just let the user pick a username that has not already been picked. Registration/Passwords are not needed. You can do them if you fancy but seriously, why? :)

The first trasport is websocket. I suggest you use the WebSocket native APIs on client side. use the "ws" module on nodejs. This part is extremely straightforward and I don't think I have to talk much about it.

The second trasport is the challenging part. It allows for offline communication using the brand new "Service Worker" standards. The idea is that the application should be usable without actually being online. The user can just type in the url for the application and type in their messages as if they were online. (The behaviour is similar to how google docs can be worked on offline.) Read up on service worker here -

http://www.html5rocks.com/en/tutorials/service-worker/introduction/

As a bonus, if you can implement this "Push Notification" option on the reciver. So that the receiver will be notified even if they are not presently browsing the demo website. This feature currently only works on chrome (which is not a problem). Read up here -

https://developers.google.com/web/updates/2015/03/push-notifications-on-the-open-web

I hope you will find this task challenging and educative at the same time.

# Testing

You need [mocha](https://github.com/mochajs/mocha)

`npm test`