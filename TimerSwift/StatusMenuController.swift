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
    case Running(String)
}

class StatusMenuController: NSObject {
    @IBOutlet weak var statusMenu: NSMenu!
    @IBOutlet weak var finishTimerMenuItem: NSMenuItem!
    @IBOutlet weak var preferencesWindow: NSWindow!

    var timerState: TimerState = .Stopped
    var menuItems = [String: NSMenuItem]()

    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    let appTimer = AppTimer()

    @IBAction func configureTasksClicked(_ sender: NSMenuItem) {
        preferencesWindow.level = .normal
        preferencesWindow.makeKeyAndOrderFront(sender)
    }

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
        guard let menuItem = menuItems[title] else {
            return
        }
        menuItem.title += " ⏱"
        timerState = .Running(title)
        finishTimerMenuItem.isEnabled = true
        menuItems.forEach { (_, menuItem) in menuItem.isEnabled = false }
        appTimer.reset()
    }

    func stop() {
        timerState = .Stopped
        finishTimerMenuItem.isEnabled = false
        menuItems.forEach { (title, menuItem) in
            menuItem.isEnabled = true
            // TODO: This is only necessary on the running task.
            menuItem.title = title
        }
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
        TimerTasksModel.shared.delegate = self
        statusItem.title = "Timer"
        statusItem.menu = statusMenu
        // Take control of whether items are enabled/disabled from the menu.
        statusMenu.autoenablesItems = false
        finishTimerMenuItem.isEnabled = false

        appTimer.addTickHandler { interval in
            if case .Running(_) = self.timerState,
                let label = StatusBarDateComponentsFromatter.string(from: interval) {
                self.statusItem.title = label
            }
        }
    }
}

extension StatusMenuController: TimerTasksModelDelegate {
    func timerTasks(didAppend title: String) {
        let item = NSMenuItem(
            title: title,
            action: #selector(StatusMenuController.timerTaskClicked(_:)),
            // TODO: No key equivalent for index >= 9
            keyEquivalent: String(menuItems.count + 1)
        )
        item.target = self
        item.isEnabled = true
        statusMenu.insertItem(item, at: 2 + menuItems.count)
        menuItems[title] = item
    }

    func timerTasks(didUpdate element: String, with newValue: String) {
        menuItems[newValue] = menuItems[element]
        menuItems[newValue]!.title = newValue
        menuItems.removeValue(forKey: element)
    }

    func timerTasks(didRemove element: String) {
        if let menuItem = menuItems.removeValue(forKey: element) {
            statusMenu.removeItem(menuItem)
            menuItems.forEach { (_, menuItem) in
                let menuPosition = statusMenu.index(of: menuItem) - 1
                menuItem.keyEquivalent = String(menuPosition)
            }
        }
    }
}
