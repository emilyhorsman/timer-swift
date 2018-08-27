import Foundation

func makeDateComponentsFormatter(
    unitsStyle: DateComponentsFormatter.UnitsStyle
) -> DateComponentsFormatter {
    let formatter = DateComponentsFormatter()
    formatter.unitsStyle = unitsStyle
    formatter.allowedUnits = [.hour, .minute, .second]
    formatter.zeroFormattingBehavior = .pad
    return formatter
}

let HumanDateComponentsFormatter = makeDateComponentsFormatter(unitsStyle: .brief)
let MachineDateComponentsFromatter = makeDateComponentsFormatter(unitsStyle: .positional)

class Timer {
    let startTime = Date()

    func tick() {
        carriageReturnPrint(HumanDateComponentsFormatter.string(from: self.interval) ?? "")
    }

    var interval: TimeInterval {
        return self.startTime.timeIntervalSinceNow
    }
}
