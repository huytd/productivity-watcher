//
//  ViewController.swift
//  ProductivityWatcher
//
//  Created by Huy Tran on 8/27/19.
//  Copyright © 2019 Huy Tran. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    let maxTimePerRound = 1500 // 25 * 60 = 1500
    let timeCounterInterval = 1.0
    let blockerInterval = 2.5
    
    var counter = 0
    
    @IBOutlet weak var labelCounter: NSTextField!
    @IBOutlet weak var labelRound: NSTextField!
    
    override func viewDidAppear() {
        super.viewDidAppear()
        self.view.window?.level = .floating
        self.view.window?.backgroundColor = NSColor(red:0.46, green:0.14, blue:0.82, alpha:1.0)
    }

    func getTodaySettingKey() -> String {
        let now = Date()
        let cal = Calendar.current
        let dd = cal.component(.day, from: now)
        let mm = cal.component(.month, from: now)
        let yy = cal.component(.year, from: now)
        return "\(dd)\(mm)\(yy)"
    }
    
    func getRoundCount() -> Int {
        return UserDefaults.standard.integer(forKey: getTodaySettingKey())
    }
    
    func saveRoundCount(count: Int) {
        UserDefaults.standard.set(count, forKey: getTodaySettingKey())
    }
    
    func updateRoundLabel() {
        let round = getRoundCount()
        self.labelRound.stringValue = "Round #\(round > 0 ? round : 1)"
    }
    
    func startTimeCounter() {
        updateRoundLabel()
        self.counter = maxTimePerRound
        Timer.scheduledTimer(withTimeInterval: timeCounterInterval, repeats: true) { (timer) in
            if (self.counter > 0) {
                self.counter -= 1
                let min = "\(self.counter / 60)".padding(toLength: 2, withPad: "0", startingAt: 0)
                let sec = "\(self.counter % 60)".padding(toLength: 2, withPad: "0", startingAt: 0)
                self.labelCounter.stringValue = "\(min):\(sec)"
            } else {
                self.labelCounter.stringValue = "Done!!!"
                timer.invalidate()
                self.onTimeCounterStop()
            }
        }
    }
    
    func onTimeCounterStop() {
        let round = getRoundCount()
        saveRoundCount(count: (round > 0 ? round : 1) + 1)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        startTimeCounter()
        
        Timer.scheduledTimer(withTimeInterval: blockerInterval, repeats: true) { timer in
            if (self.counter > 0) {
                let task = Process()
                task.launchPath = "/usr/bin/osascript"
                task.arguments = [ Bundle.main.path(forResource: "appblocker", ofType: "scpt")! ]
                task.launch()
            }
        }
    }

    override func mouseDown(with event: NSEvent) {
        if (event.clickCount == 2 && self.counter == 0) {
            startTimeCounter()
        }
    }
    
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

