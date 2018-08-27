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
let StatusBarDateComponentsFromatter = makeDateComponentsFormatter(unitsStyle: .positional)

class AppTimer {
    var startTime = Date()
    var timer: Timer?
    var tickHandlers = [(TimeInterval) -> Void]()

    init() {
        timer = Timer.scheduledTimer(
            withTimeInterval: 1,
            repeats: true
        ) { (timer: Timer) -> Void in
            self.tick()
        }
    }

    deinit {
        if let t = timer {
            t.invalidate()
        }
    }

    func addTickHandler(handler: @escaping (TimeInterval) -> Void) -> Void {
        tickHandlers.append(handler)
    }

    func reset() {
        startTime = Date()
        timer?.fire()
    }

    func tick() {
        tickHandlers.forEach { (handler) -> Void in
            handler(interval)
        }
    }

    var interval: TimeInterval {
        return startTime.timeIntervalSinceNow
    }
}
