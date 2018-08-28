//
//  TimerTasksController.swift
//  TimerSwift
//
//  Created by Emily Horsman on 8/28/18.
//  Copyright © 2018 Emily Horsman. All rights reserved.
//

import Cocoa

extension Array {
    mutating func removeIndices(in indices: IndexSet) {
        var count = 0
        indices.forEach { index in
            remove(at: index - count)
            count += 1
        }
    }
}

class TimerTasksController: NSObject {
    @IBOutlet weak var timerTasksTableView: NSTableView!
    @IBOutlet weak var removeButton: NSButton!

    var data = [
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
        removeButton.isEnabled = false
    }

    @IBAction func addClicked(_ sender: Any) {
        print("Add!")
    }

    @IBAction func removeClicked(_ sender: Any) {
        data.removeIndices(in: timerTasksTableView.selectedRowIndexes)
        timerTasksTableView.reloadData()
    }
}

extension TimerTasksController: NSTextFieldDelegate {
    override func controlTextDidEndEditing(_ obj: Notification) {
        // TODO: Prevent blank entries.
        guard let textField = obj.object as? NSTextField else {
            return
        }
        let row = textField.tag
        guard row >= 0 && row < data.count else {
            return
        }
        data[row] = textField.stringValue
        // Probably unnecessary but it's just text (thus cheap?) and builds
        // confidence that the backing data is synced.
        timerTasksTableView.reloadData(
            forRowIndexes: IndexSet(integer: row),
            columnIndexes: IndexSet(integer: 0)
        )
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
        guard let textField = cell.textField else {
            return nil
        }
        textField.stringValue = data[row]
        textField.isEditable = true
        textField.delegate = self
        textField.tag = row

        return cell
    }

    func tableViewSelectionDidChange(_ notification: Notification) {
        // Imperative view logic ugh
        if timerTasksTableView.numberOfSelectedRows == 0 {
            removeButton.isEnabled = false
            return
        }
        removeButton.isEnabled = true
    }
}
