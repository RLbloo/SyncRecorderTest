//
//  ViewController.swift
//  SyncedRecorderTest
//
//  Created by Richard Leeds on 12/08/2016.
//  Copyright © 2016 Richard Leeds. All rights reserved.
//

import UIKit
import MultipeerConnectivity
import AVFoundation
import AudioKit

var hostMode = false

var machineTime = Double(NSDate.timeIntervalSinceReferenceDate() / 1000)

var sentAt = Int()

var recievedAt = Int()

var latency = Double()

var offsetTime = Double()

var machTime = String()

var clientSynced = false

var sessionSynced = false

var hostName = String()

var clientTime = String()

var timer = NSTimer()

var localTime = NSDate(timeIntervalSinceNow: 0)

var hostTime = NSDate(timeIntervalSinceNow: 0)




var milliseconds = 0

var timerIsOn = false

var latencyTolerance = 3.0

class MPCSwitchViewController: UIViewController {
    
    @IBOutlet weak var connectionsLabel: UILabel!
    
    @IBOutlet weak var hostNameLabel: UILabel!
    @IBOutlet weak var clientLatencyLabel: UILabel!
    
    @IBOutlet weak var isHostLabel: UILabel!
    
    
    @IBOutlet weak var latencyTolLabel: UILabel!
    
    let MPCService = MPCServiceManager()
    
    var StartTime = mach_absolute_time
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        MPCService.delegate = self
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: (#selector(MPCSwitchViewController.updateTimer)), userInfo: nil, repeats: true)
        
        
        latencyStepper.wraps = true
        latencyStepper.autorepeat = false
        latencyStepper.minimumValue = 1.0
        latencyStepper.maximumValue = 10.0
        
        latencyTolLabel.text = ("\(3.0) milliseconds")
        
        
        
    
        
        
        
        
    }
    
    func updateTimer(){
        milliseconds += 1
        
        
        
        offsetTime = (Double(NSDate.timeIntervalSinceReferenceDate() * 1000) - machineTime)
        machTime = String(offsetTime)
        
        //        MPCService.sendTime(offsetString)
        
        if hostMode == false {
            hostNameLabel.text = hostName
            isHostLabel.text = ("Client")
            
            clientLatencyLabel.text = String(latency)
            
        }
        
        if hostMode == true {
            isHostLabel.text = ("Host")
            
            
            
            
        }
        
        
        
        
        
    }
    
    
    
    //    Starts Host Mode sync
    @IBAction func hostTapped(sender: AnyObject) {
        
        hostMode = true
        MPCService.send("host")
        
        
        
    }
    
    //    Cancels Host Mode Sync
    @IBAction func cancelTapped(sender: AnyObject) {
        hostMode = false
        MPCService.send("cancel")
        
        
    }
    
    @IBOutlet weak var latencyStepper: UIStepper!
    
    @IBAction func latencyStepperValueChanged(sender: AnyObject) {
        // create a sound ID, in this case its the tweet sound.
        let systemSoundID: SystemSoundID = 1016
        
        // to play sound
        AudioServicesPlaySystemSound (systemSoundID)
        latencyTolerance = (sender.value)
        
        latencyTolLabel.text = (String(latencyTolerance))
        
    }
    
    
    

    
    @IBAction func pluck(sender: AnyObject) {
        
        
        MPCService.send("record in 3 seconds")
        
    }
    
    
    
    
    
}

extension MPCSwitchViewController : MPCServiceManagerDelegate {
func connectedDevicesChanged(manager: MPCServiceManager, connectedDevices: [String]) {
    NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
        self.connectionsLabel.text = "Connections: \(connectedDevices)"
    }
}

}
//