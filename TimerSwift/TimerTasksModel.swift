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

class TimerTasksModel {
    private var data = [String]()

    func append(_ element: String) {
        data.append(element)
    }

    func removeIndices(in indices: IndexSet) {
        data.removeIndices(in: indices)
    }

    subscript(index: Int) -> String {
        get {
            return data[index]
        }

        set(newValue) {
            data[index] = newValue
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
