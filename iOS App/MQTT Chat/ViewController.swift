//
//  ViewController.swift
//  MQTT Chat
//
//  Created by Dennis Dreissen on 28-09-15.
//  Copyright © 2015 Dennis Dreissen. All rights reserved.
//

import UIKit
import MQTTKit
import JSQMessagesViewController

class ViewController: JSQMessagesViewController {
    
    // Host and channel variables.
    let HOST = "iot.eclipse.org"
    let TOPIC = "iOSChatApp"
    
    // The clientId variable, right now this is the device UUID.
    var clientId: String = UIDevice.currentDevice().identifierForVendor!.UUIDString
    
    // Variable which contains the client.
    var client: MQTTClient?
    
    // Array which contains all the sent and received messages, everything in this array will be displayed on the screen.
    var messages = [JSQMessage]()
    
    // The incoming and outgoing message bubble design.
    let incomingBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImageWithColor(UIColor(red: 10/255, green: 180/255, blue: 230/255, alpha: 1.0))
    let outgoingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImageWithColor(UIColor.lightGrayColor())

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initiate the client.
        client = MQTTClient(clientId: self.clientId, cleanSession: false)
        
        // SenderId and senderDisplayName, required by the JSQMessages library.
        self.senderId = self.clientId
        self.senderDisplayName = self.clientId
        
        // Connect to the MQTT server and show a connected message to the local user.
        self.client!.connectToHost(self.HOST, completionHandler: { (code: MQTTConnectionReturnCode) in
            if (code.rawValue == 0) {
                let message = JSQMessage(senderId: self.clientId, displayName: self.clientId, text: "You're now connected! Have fun.")
                self.messages += [message]
                self.reloadCollectionView()
                
                // Subscribe to the specified topic.
                self.client?.subscribe(self.TOPIC, withQos: AtLeastOnce, completionHandler: nil)
            }
        })
        
        // The message handler callback, all messaes posted on the subscribed topics pass through this function and will be added to the messages array.
        self.client?.messageHandler = { message in
            let payloadData = message.payloadString().componentsSeparatedByString(";;")
            if (payloadData.count == 2) {
                let message = JSQMessage(senderId: payloadData[1], displayName: payloadData[1], text: payloadData[0])
                self.messages += [message]
                self.reloadCollectionView()
            }
        }
        
        // Couple of settings that hide avatars and give the buddles a "springiness" effect.
        self.collectionView?.collectionViewLayout.incomingAvatarViewSize = CGSizeZero
        self.collectionView?.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero
        self.collectionView?.collectionViewLayout.springinessEnabled = true
        
        // Remove the attachment button on the left.
        self.inputToolbar!.contentView!.leftBarButtonItem = nil
    }
    
    // Function that publishes a message to the server.
    func pubMessage (message: String) {
        self.client?.publishString(message + ";;" + self.clientId, toTopic: self.TOPIC, withQos: AtLeastOnce, retain: false, completionHandler: { (mid: Int32) in
            print("Message has been delivered to the server")
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.p
        
    }
    
    func reloadCollectionView() {
        dispatch_async(dispatch_get_main_queue(), {
            self.collectionView!.reloadData()
        })
    }

    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        let data = self.messages[indexPath.row]
        return data
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        let data = self.messages[indexPath.row]
        if (data.senderId == self.clientId) {
            return self.outgoingBubble
        } else {
            return self.incomingBubble
        }
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.messages.count;
    }
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        self.pubMessage(text)
        self.finishSendingMessage()
    }
}
