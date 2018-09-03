//
//  TimerTasksController.swift
//  TimerSwift
//
//  Created by Emily Horsman on 8/28/18.
//  Copyright © 2018 Emily Horsman. All rights reserved.
//

import Cocoa

class PreferencesWindowController: NSViewController {
    @IBOutlet weak var timerTasksTableView: NSTableView!
    @IBOutlet weak var removeButton: NSButton!
    @IBOutlet weak var loggingPathControl: NSPathControl!

    override func viewDidLoad() {
        super.viewDidLoad()
        TimerTasksModel.shared.loadData()
        timerTasksTableView.dataSource = self
        timerTasksTableView.delegate = self
        removeButton.isEnabled = false

        if let path = TimerTasksModel.shared.loggingPath {
            loggingPathControl.url = URL(string: path)
        }
    }

    @IBAction func addClicked(_ sender: Any) {
        TimerTasksModel.shared.append("New Timer")
        timerTasksTableView.reloadData()
    }

    @IBAction func removeClicked(_ sender: Any) {
        TimerTasksModel.shared.removeIndices(in: timerTasksTableView.selectedRowIndexes)
        timerTasksTableView.reloadData()
    }
}

extension PreferencesWindowController: NSTextFieldDelegate {
    func controlTextDidEndEditing(_ obj: Notification) {
        // TODO: Prevent blank entries.
        guard let textField = obj.object as? NSTextField else {
            return
        }
        guard TimerTasksModel.shared.update(fromTextFieldWithTag: textField) else {
            return
        }
        // Probably unnecessary but it's just text (thus cheap?) and builds
        // confidence that the backing data is synced.
        timerTasksTableView.reloadData(
            forRowIndexes: IndexSet(integer: textField.tag),
            columnIndexes: IndexSet(integer: 0)
        )
    }
}


extension PreferencesWindowController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return TimerTasksModel.shared.count
    }
}

extension PreferencesWindowController: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard TimerTasksModel.shared.has(index: row) else {
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
        textField.stringValue = TimerTasksModel.shared[row]
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
