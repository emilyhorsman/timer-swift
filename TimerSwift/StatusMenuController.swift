//
//  StatusMenuController.swift
//  TimerSwift
//
//  Created by Emily Horsman on 8/27/18.
//  Copyright © 2018 Emily Horsman. All rights reserved.
//

import Cocoa

enum TimerState {
    case Stopped
    case Running(TimerTask)
}

struct TimerTask {
    let title: String
    let menuItem: NSMenuItem
}

class StatusMenuController: NSObject {
    @IBOutlet weak var statusMenu: NSMenu!
    @IBOutlet weak var finishTimerMenuItem: NSMenuItem!

    var timerState: TimerState = .Stopped

    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    let appTimer = AppTimer()
    var timerTasks = [TimerTask]()

    @IBAction func quitClicked(_ sender: NSMenuItem) {
        NSApp.terminate(self)
    }

    @IBAction func finishTimerClicked(_ sender: NSMenuItem) {
        guard case .Running(_) = timerState else {
            return assertionFailure("finishTimerClicked action fired when timer was not Running")
        }

        stop()
    }

    func start(title: String) {
        let task = timerTasks.first(where: { $0.title == title })!
        timerState = .Running(task)
        finishTimerMenuItem.isEnabled = true
        timerTasks.forEach { $0.menuItem.isEnabled = false }
        appTimer.reset()
    }

    func stop() {
        timerState = .Stopped
        finishTimerMenuItem.isEnabled = false
        timerTasks.forEach { $0.menuItem.isEnabled = true }
        statusItem.title = "Timer"
    }

    @IBAction func timerTaskClicked(_ sender: NSMenuItem) {
        // TODO: If we're currently Running then it should log that and switch
        // to a new task.
        guard case .Stopped = timerState else {
            return assertionFailure("timerTaskClicked action fired when timer was not Running")
        }

        start(title: sender.title)
    }

    override func awakeFromNib() {
        statusItem.title = "Timer"
        statusItem.menu = statusMenu
        // Take control of whether items are enabled/disabled from the menu.
        statusMenu.autoenablesItems = false
        finishTimerMenuItem.isEnabled = false

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
            if case .Running(_) = self.timerState,
                let label = StatusBarDateComponentsFromatter.string(from: interval) {
                self.statusItem.title = label
            }
        }
    }
}
