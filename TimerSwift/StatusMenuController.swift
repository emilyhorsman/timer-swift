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

struct TimerTask {
    let title: String
    let menuItem: NSMenuItem
}

class StatusMenuController: NSObject {
    @IBOutlet weak var statusMenu: NSMenu!
    @IBOutlet weak var timerMenuItem: NSMenuItem!

    var timerState: TimerState = .Stopped

    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    let appTimer = AppTimer()
    var timerTasks = [TimerTask]()

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

    @IBAction func timerTaskClicked(_ sender: NSMenuItem) {
        print(sender.title)
    }

    override func awakeFromNib() {
        statusItem.title = "Timer"
        statusItem.menu = statusMenu

        ["3DB3", "3GC3", "3MI3", "3SD3", "4HC3"].forEach { title in
            let item = NSMenuItem(
                title: title,
                action: #selector(StatusMenuController.timerTaskClicked(_:)),
                keyEquivalent: ""
            )
            item.target = self
            item.isEnabled = true
            statusMenu.addItem(item)
            timerTasks.append(TimerTask(title: title, menuItem: item))
        }


        appTimer.addTickHandler { interval in
            if self.timerState == .Running,
                let label = StatusBarDateComponentsFromatter.string(from: interval) {
                self.statusItem.title = label
            }
        }
    }
}
