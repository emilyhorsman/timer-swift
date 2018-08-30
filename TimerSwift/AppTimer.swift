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
        timer = Timer.init(
            timeInterval: 1,
            repeats: true
        ) { _ in
            self.tick()
        }
        // Avoiding scheduledTimer with the default run loop mode because we
        // want to be able to update the UI (e.g., the timer/NSMenu title) while
        // the menu is open.
        RunLoop.current.add(timer!, forMode: RunLoop.Mode.common)
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
        tickHandlers.forEach { handler in
            handler(interval)
        }
    }

    var interval: TimeInterval {
        return startTime.timeIntervalSinceNow
    }
}
