//
//  StatusMenuController.swift
//  TimerSwift
//
//  Created by Emily Horsman on 8/27/18.
//  Copyright © 2018 Emily Horsman. All rights reserved.
//

import Cocoa

enum TimerState {
    case Stopped, Running
}

class StatusMenuController: NSObject {
    @IBOutlet weak var statusMenu: NSMenu!
    @IBOutlet weak var timerMenuItem: NSMenuItem!

    var timerState: TimerState = .Stopped

    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    let appTimer = AppTimer()

    @IBAction func quitClicked(_ sender: NSMenuItem) {
        NSApp.terminate(self)
    }

    @IBAction func timerClicked(_ sender: NSMenuItem) {
        switch timerState {
        case .Running:
            stop()
        case .Stopped:
            start()
        }
    }

    func start() {
        timerState = .Running
        timerMenuItem.title = "Stop"
        appTimer.reset()
    }

    func stop() {
        timerState = .Stopped
        timerMenuItem.title = "Start"
        statusItem.title = "Timer"
    }

    override func awakeFromNib() {
        statusItem.title = "Timer"
        statusItem.menu = statusMenu

        appTimer.addTickHandler { interval in
            if self.timerState == .Running,
                let label = StatusBarDateComponentsFromatter.string(from: interval) {
                self.statusItem.title = label
            }
        }
    }
}
