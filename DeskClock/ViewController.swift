//
//  ViewController.swift
//  DeskClock
//
//  Created by Huy Tran on 8/27/19.
//  Copyright © 2019 Huy Tran. All rights reserved.
//

// ✕ ○ ✕ ○ ✕ ○ ✕ ○ ✕ ○ ✕ ○ ✕ ○ ✕ ○ ✕ ○ ✕ ○ ✕ ○ ✕ ○ ✕ ○ ✕ ○ ✕ ○ ✕ ○ ✕ ○ ✕ ○ ✕ ○ ✕ ○ ✕ ○ ✕ ○ ✕ ○ 

import Cocoa
import UserNotifications

extension String {
    func leftPadding(toLength: Int, withPad character: Character) -> String {
        let newLength = self.count
        if newLength < toLength {
            return String(repeatElement(character, count: toLength - newLength)) + self
        } else {
            return self.substring(from: index(self.startIndex, offsetBy: newLength - toLength))
        }
    }
}

class ViewController: NSViewController {
    let timeCounterInterval = 1.0
    let appHideInterval = 5
    var counterMode = false
    var counter = 0
    var appHideCounter = 0
    var currentStreak = 0
    var targetTimeCounter = 30
    var canShowNotification = false

    @IBOutlet weak var labelTime: NSTextField!
    @IBOutlet weak var labelCounter: NSTextField!
    
    func counterToString(counter: Int) -> String {
        let min = "\(counter / 60)".leftPadding(toLength: 2, withPad: "0")
        let sec = "\(counter % 60)".leftPadding(toLength: 2, withPad: "0")
        return "\(min):\(sec)"
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        self.view.window?.level = .floating
        self.view.window?.backgroundColor = NSColor(red:1.0, green:1.0, blue:1.0, alpha:1.0)
    }
    
    override func scrollWheel(with event: NSEvent) {
        let isInc = event.deltaY < 0
        if (isInc) {
            if (targetTimeCounter < 90) {
                targetTimeCounter += 5
            }
        } else {
            if (targetTimeCounter > 5) {
                targetTimeCounter -= 5
            }
        }
        self.labelCounter.stringValue = counterToString(counter: targetTimeCounter * 60)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Timer.scheduledTimer(withTimeInterval: timeCounterInterval, repeats: true) { timer in
            
            // Update clock
            let now = Date()
            let cal = Calendar.current
            let hour = "\(cal.component(.hour, from: now))".leftPadding(toLength: 2, withPad: "0")
            let minutes = "\(cal.component(.minute, from: now))".leftPadding(toLength: 2, withPad: "0")
            self.labelTime.stringValue = "\(hour):\(minutes)"
            
            if self.counterMode {
                if self.counter > 0 {
                    self.counter -= 1
                    self.labelCounter.stringValue = self.counterToString(counter: self.counter)
                } else {
                    self.labelCounter.stringValue = "done"
                    self.finalizeRound()
                }
            }
        }
        
        switchToClock()
        
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
            if let error = error {
                print("Can't have notification!")
            }
            print("Good, we'll have notification!")
            self.canShowNotification = true
        }
    }
    
    func scheduleNotification() {
        let center = UNUserNotificationCenter.current()

        let content = UNMutableNotificationContent()
        content.title = "Time up!"
        content.body = "Great! You've spent \(targetTimeCounter) productive minutes!"
        content.categoryIdentifier = "alarm"
        content.userInfo = ["customData": "fizzbuzz"]
        content.sound = UNNotificationSound.default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        center.add(request)
    }
    
    func finalizeRound() {
        self.counterMode = false
        self.labelCounter.stringValue = "done!"
        self.scheduleNotification()
    }
    
    func switchToClock() {
        counterMode = false
        self.labelCounter.stringValue = counterToString(counter: targetTimeCounter * 60)
        self.labelTime.textColor = NSColor(red:0.0, green:0.0, blue:0.0, alpha:1.0)
        self.labelCounter.textColor = NSColor(red:0.0, green:0.0, blue:0.0, alpha:0.35)
    }
    
    func switchToTimer() {
        counterMode = true
        counter = 5 //60 * self.targetTimeCounter
        self.labelTime.textColor = NSColor(red:0.0, green:0.0, blue:0.0, alpha:0.35)
        self.labelCounter.textColor = NSColor(red:0.0, green:0.0, blue:0.0, alpha:1.0)
    }
    
    override func mouseDown(with event: NSEvent) {
        if event.clickCount >= 2 {
            if !counterMode {
                switchToTimer()
            } else {
                switchToClock()
            }
        }
    }
    
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

