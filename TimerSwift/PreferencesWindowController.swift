//
//  PreferencesWindowController.swift
//  TimerSwift
//
//  Created by Emily Horsman on 8/28/18.
//  Copyright © 2018 Emily Horsman. All rights reserved.
//

import Cocoa

class TimerTaskRow: NSObject {
    @objc dynamic var title: String

    override init() {
        self.title = "New Task"
        super.init()
    }
}

class PreferencesWindowController: NSViewController {

    @IBOutlet weak var timerTasks: NSArrayController!
    @objc dynamic var dataArray = [TimerTaskRow]()

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func addClicked(_ sender: NSButtonCell) {
        timerTasks.add(TimerTaskRow())
    }

}
