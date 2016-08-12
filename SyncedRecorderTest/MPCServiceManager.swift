//
//  MPCServiceManager.swift
//  SyncedRecorderTest
//
//  Created by Richard Leeds on 12/08/2016.
//  Copyright © 2016 Richard Leeds. All rights reserved.
//


import Foundation
import MultipeerConnectivity

protocol MPCServiceManagerDelegate {
    
    func connectedDevicesChanged(manager : MPCServiceManager, connectedDevices: [String])
    
}

class MPCServiceManager : NSObject {
    
    
    
    private let MPCServiceType = "example-MPC"
    private let myPeerId = MCPeerID(displayName: UIDevice.currentDevice().name)
    private let serviceAdvertiser : MCNearbyServiceAdvertiser
    private let serviceBrowser : MCNearbyServiceBrowser
    var foundPeers = [MCPeerID]()
    var delegate : MPCServiceManagerDelegate?
    
    override init() {
        self.serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerId, discoveryInfo: nil, serviceType: MPCServiceType)
        
        self.serviceBrowser = MCNearbyServiceBrowser(peer: myPeerId, serviceType: MPCServiceType)
        
        super.init()
        
        self.serviceAdvertiser.delegate = self
        self.serviceAdvertiser.startAdvertisingPeer()
        
        self.serviceBrowser.delegate = self
        self.serviceBrowser.startBrowsingForPeers()
    }
    
    deinit {
        self.serviceAdvertiser.stopAdvertisingPeer()
        self.serviceBrowser.stopBrowsingForPeers()
    }
    
    lazy var session: MCSession = {
        let session = MCSession(peer: self.myPeerId, securityIdentity: nil, encryptionPreference: MCEncryptionPreference.Required)
        session.delegate = self
        return session
    }()
    
    func send(MPCName : String) {
        NSLog(MPCName)
        
        if session.connectedPeers.count > 0 {
            var error : NSError?
            do {
                try self.session.sendData(MPCName.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, toPeers: session.connectedPeers, withMode: MCSessionSendDataMode.Reliable)
            } catch let error1 as NSError {
                error = error1
                NSLog("%@", "\(error)")
            }
        }
        
        
    }
    
    func sendTime(machTime : String) {
        NSLog("Send machine time \(machTime)")
        
        if session.connectedPeers.count > 0 {
            var error : NSError?
            do {
                try self.session.sendData(machTime.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, toPeers: session.connectedPeers, withMode: MCSessionSendDataMode.Reliable)
            } catch let error1 as NSError {
                error = error1
                NSLog("%@", "\(error)")
            }
        }
        
        
        
        
        
        
    }
    
    
    
    
    //    func advanceTimer(timer: NSTimer)
    //    {
    //        //The rest of your code goes here
    //
    //        self.send(myPeerId.displayName)
    //        print("still Checking")
    //    }
    
    
    
    func syncTimer(){
        self.send(myPeerId.displayName)
        print("still Checking")
    }
    
    

}

extension MPCServiceManager : MCNearbyServiceAdvertiserDelegate {
    
    func advertiser(advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: NSError) {
        NSLog("%@", "didNotStartAdvertisingPeer: \(error)")
    }
    
    func advertiser(advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: NSData?, invitationHandler: ((Bool, MCSession) -> Void)) {
        
        NSLog("%@", "didReceiveInvitationFromPeer \(peerID)")
        invitationHandler(true, self.session)
    }
    
}

extension MPCServiceManager : MCNearbyServiceBrowserDelegate {
    
    func browser(browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: NSError) {
        NSLog("%@", "didNotStartBrowsingForPeers: \(error)")
    }
    
    func browser(browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        NSLog("%@", "foundPeer: \(peerID)")
        NSLog("%@", "invitePeer: \(peerID)")
        browser.invitePeer(peerID, toSession: self.session, withContext: nil, timeout: 10)
    }
    
    func browser(browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        NSLog("%@", "lostPeer: \(peerID)")
    }
    
}

extension MCSessionState {
    
    func stringValue() -> String {
        
        switch(self) {
        case .NotConnected: return "NotConnected"
        case .Connecting: return "Connecting"
        case .Connected: return "Connected"
        default: return "Unknown"
        }
    }
    
}

extension MPCServiceManager : MCSessionDelegate {
    
    func session(session: MCSession, peer peerID: MCPeerID, didChangeState state: MCSessionState) {
        NSLog("%@", "peer \(peerID) didChangeState: \(state.stringValue())")
        self.delegate?.connectedDevicesChanged(self, connectedDevices: session.connectedPeers.map({$0.displayName}))
    }
    
    func session(session: MCSession, didReceiveData data: NSData, fromPeer peerID: MCPeerID) {
        NSLog("%@", "didReceiveData: \(data.length) bytes")
        let str = NSString(data: data, encoding: NSUTF8StringEncoding) as! String
        
        
        
        
        
        if str == (myPeerId.displayName){
            
            
            
            latency = ((Double(NSDate.timeIntervalSinceReferenceDate() * 1000) - machineTime)  /  2)
            
            
            
            //            Latency Tolerance in milliseconds
            
            
            
            if  latency >= latencyTolerance {
                
                //                //Start the timer
                //
                //                var startTime: NSTimeInterval
                //
                //                startTime = NSDate.timeIntervalSinceReferenceDate()
                //                NSTimer.scheduledTimerWithTimeInterval(0.5,
                //                                                       target: self,
                //                                                       selector: #selector(MPCServiceManager.advanceTimer(_:)),
                //                                                       userInfo: nil,
                //                                                       repeats: true)
                machineTime = (Double(NSDate.timeIntervalSinceReferenceDate()) * 1000)
                self.send(self.myPeerId.displayName)
                print(latency)
                print(latency)
                print(latency)
                
            }
            
        }
        
        if str == ("host"){
            hostMode = false
            hostName = peerID.displayName
            print("recieved 'host' from host")
            machineTime = (Double(NSDate.timeIntervalSinceReferenceDate()) * 1000)
            
            self.send(myPeerId.displayName)
            print("string sent")
            
        }
        
        
        
        if hostMode == true {
            
            self.send(str)
            
            
        }
        
        if str == ("cancel"){
            
            
            return
            
            
        }
        
        
        print(str)
        
        
        
    }
    
    
    
    func session(session: MCSession, didReceiveStream stream: NSInputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        NSLog("%@", "didReceiveStream")
    }
    
    func session(session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, atURL localURL: NSURL, withError error: NSError?) {
        NSLog("%@", "didFinishReceivingResourceWithName")
    }
    
    func session(session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, withProgress progress: NSProgress) {
        NSLog("%@", "didStartReceivingResourceWithName")
    }
    
}
