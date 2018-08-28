//
//  TimerTasksController.swift
//  TimerSwift
//
//  Created by Emily Horsman on 8/28/18.
//  Copyright © 2018 Emily Horsman. All rights reserved.
//

import Cocoa

class TimerTasksController: NSObject {
    @IBOutlet weak var timerTasksTableView: NSTableView!

    let data = [
        "3DB3",
        "3GC3",
        "3MI3",
        "3SD3",
        "4HC3",
    ]

    override func awakeFromNib() {
        super.awakeFromNib()
        // TODO: There's probably a better part of the lifecycle to put this
        // in but eh idk it's my first AppKit thing alright ¯\_(ツ)_/¯.
        timerTasksTableView.dataSource = self
        timerTasksTableView.delegate = self
    }
}

extension TimerTasksController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return data.count
    }
}

extension TimerTasksController: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard row >= 0 && row < data.count else {
            return nil
        }

        if tableColumn == tableView.tableColumns[0] {
            return makeTaskCell(tableView, forRow: row)
        }

        return nil
    }

    func makeTaskCell(_ tableView: NSTableView, forRow row: Int) -> NSTableCellView? {
        guard let cell = tableView.makeView(
            withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "TaskCell"),
            owner: nil
            ) as? NSTableCellView else {
            return nil
        }

        cell.textField?.stringValue = data[row]
        return cell
    }
}
