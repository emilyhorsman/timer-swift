//
//  TimerTasksModel.swift
//  TimerSwift
//
//  Created by Emily Horsman on 8/28/18.
//  Copyright © 2018 Emily Horsman. All rights reserved.
//

import Cocoa
import Foundation

extension Array {
    mutating func removeIndices(in indices: IndexSet) {
        var count = 0
        indices.forEach { index in
            remove(at: index - count)
            count += 1
        }
    }
}

protocol TimerTasksModelDelegate {
    func timerTasks(didAppend element: String)

    func timerTasks(didUpdate element: String, with newValue: String)

    func timerTasks(didRemove element: String)
}

class TimerTasksModel: NSObject {
    static let shared = TimerTasksModel()

    private var data = [String]()
    var delegate: TimerTasksModelDelegate?

    private override init() {
        super.init()
    }

    func loadData() {
        do {
            let contents = try String(contentsOf: dataPath, encoding: .utf8)
            contents.split(separator: "\n").forEach { line in
                append(String(line))
            }
        } catch {
            print(error)
        }
    }

    func saveData() {
        do {
            try data.joined(separator: "\n").write(
                to: dataPath,
                atomically: false,
                encoding: .utf8
            )
        } catch {
            print(error)
        }
    }

    private var dataPath: URL {
        get {
            return URL(
                fileURLWithPath: NSHomeDirectory(),
                isDirectory: true
            ).appendingPathComponent("TimerTasksList")
        }
    }

    func append(_ element: String) {
        data.append(element)
        if let d = delegate {
            d.timerTasks(didAppend: element)
        }
    }

    func removeIndices(in indices: IndexSet) {
        let titles = indices.map { data[$0] }
        data.removeIndices(in: indices)
        if let d = delegate {
            titles.forEach { title in
                d.timerTasks(didRemove: title)
            }
        }
    }

    subscript(index: Int) -> String {
        get {
            return data[index]
        }

        set(newValue) {
            let oldValue = data[index]
            data[index] = newValue
            if let d = delegate {
                d.timerTasks(didUpdate: oldValue, with: newValue)
            }
        }
    }

    func update(fromTextFieldWithTag textField: NSTextField) -> Bool {
        let row = textField.tag
        guard has(index: row) else {
            return false
        }

        self[row] = textField.stringValue
        return true
    }

    var count: Int {
        get {
            return data.count
        }
    }

    func has(index: Int) -> Bool {
        return index >= 0 && index < data.count
    }
}
