# iOS Chat Application

Basic iOS chat application using a Node.JS backed running the [Mosca](https://www.npmjs.com/package/mosca) MQTT broker. Requires Node.JS, NPM and MongoDB to be installed on your server. If you don't want to run your own server you can use iot.eclipse.org.

Setting up the Node.JS server is easy, assuming you have installed everything mentioned above. Download the 2 files inside the server folder and run the command "npm install". This should install Mosca and all its required dependencies. After that's done run "node index.js" and you're good to go. Make sure the host variable inside the iOS app (ViewController.swift) points to your server.

Use .xcworkspace when opening the project, this because the app is using the following pods:

- [JSQMessagesViewController](https://github.com/jessesquires/JSQMessagesViewController)
- [MQTTKit](https://github.com/mobile-web-messaging/MQTTKit)

![](http://puu.sh/kvYL7/423229aede.PNG | width=10)
