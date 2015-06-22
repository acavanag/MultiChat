//
//  ChatManager.swift
//  MultiChat
//
//  Created by Andrew Cavanagh on 6/21/15.
//  Copyright (c) 2015 WeddingWire. All rights reserved.
//

import Foundation
import MultipeerConnectivity

struct Message {
    var peer: MCPeerID?
    var message: String
}

protocol MessageResponderDelegate: class, NSObjectProtocol {
    func didReceiveMessage(message: Message)
}

private let cm_serviceType = "cm-chat-service"

class SessionManager: NSObject {
    
    lazy var session : MCSession = {
        let session = MCSession(peer: self.localPeer, securityIdentity: nil, encryptionPreference: .None)
        session?.delegate = self
        return session
    }()
    
    private var localPeer: MCPeerID
    private var advertiser: MCNearbyServiceAdvertiser
    private var browser: MCNearbyServiceBrowser
    
    private weak var delegate: MessageResponderDelegate?
    
    private(set) var isAdvertising: Bool = false
    private(set) var isBrowsing: Bool = false
    
    init(displayName: String = UIDevice.currentDevice().name, delegate: MessageResponderDelegate) {
        localPeer = MCPeerID(displayName: displayName)

        browser = MCNearbyServiceBrowser(peer: localPeer, serviceType: cm_serviceType)
        advertiser = MCNearbyServiceAdvertiser(peer: localPeer, discoveryInfo: nil, serviceType: cm_serviceType)
        
        self.delegate = delegate
        
        super.init()
        
        advertiser.delegate = self
        browser.delegate = self
        
        browse(true)
        advertise(true)
    }
    
    // MARK: - Browsing / Advertising
    
    private func advertise(advertise: Bool) {
        if advertise {
            advertiser.startAdvertisingPeer()
        } else {
            advertiser.stopAdvertisingPeer()
        }
        isAdvertising = !isAdvertising
    }
    
    private func browse(browse: Bool) {
        if browse {
            browser.startBrowsingForPeers()
        } else {
            browser.stopBrowsingForPeers()
        }
        isBrowsing = !isBrowsing
    }
    
    // MARK: - Abstracted Data Handling
    
    func writeMessage(message: String) {
        if let data = message.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true) {
            writeData(data)
        }
    }
    
    private func writeData(data: NSData) {
        var error: NSError?
        session.sendData(data, toPeers: session.connectedPeers, withMode: .Reliable, error: &error)
        if error == nil {
            readData(data, peer: localPeer)
        }
    }
    
    private func readData(data: NSData, peer: MCPeerID) {
        if let data = NSString(data: data, encoding: NSUTF8StringEncoding) as? String {
            delegate?.didReceiveMessage(Message(peer: peer, message: data))
        }
    }

}

// MARK: - Browser Delegate

extension SessionManager: MCNearbyServiceBrowserDelegate {
    
    func browser(browser: MCNearbyServiceBrowser!, foundPeer peerID: MCPeerID!, withDiscoveryInfo info: [NSObject : AnyObject]!) {
        browser.invitePeer(peerID, toSession: session, withContext: nil, timeout: 10)
    }
    
    func browser(browser: MCNearbyServiceBrowser!, lostPeer peerID: MCPeerID!) {
        //noop
    }
    
}

// MARK: - Advertiser Delegate

extension SessionManager: MCNearbyServiceAdvertiserDelegate {
    
    func advertiser(advertiser: MCNearbyServiceAdvertiser!, didReceiveInvitationFromPeer peerID: MCPeerID!, withContext context: NSData!, invitationHandler: ((Bool, MCSession!) -> Void)!) {
        invitationHandler(true, session)
    }
    
}

// MARK: - Session Delegate

extension SessionManager: MCSessionDelegate {
    
    func session(session: MCSession!, didReceiveData data: NSData!, fromPeer peerID: MCPeerID!) {
        readData(data, peer: peerID)
    }
    
    func session(session: MCSession!, peer peerID: MCPeerID!, didChangeState state: MCSessionState) {
        //noop
    }
    
    func session(session: MCSession!, didFinishReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, atURL localURL: NSURL!, withError error: NSError!) {
        //noop
    }
    
    func session(session: MCSession!, didReceiveStream stream: NSInputStream!, withName streamName: String!, fromPeer peerID: MCPeerID!) {
        //noop
    }
    
    func session(session: MCSession!, didStartReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, withProgress progress: NSProgress!) {
        //noop
    }
    
}


