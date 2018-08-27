import Foundation

protocol SIGINTHandler {
    static func install(onSignal: @escaping () -> Void) -> DispatchSourceSignal
}

struct GCD: SIGINTHandler {
    /**
     * You must ensure the returned DispatchSourceSignal adoptor instance is not
     * disposed.
     */
    static func install(onSignal: @escaping () -> Void) -> DispatchSourceSignal {
        // Ensure the signal is ignored and captured here consistently.
        signal(SIGINT, SIG_IGN)

        let signalDispatchSource = DispatchSource.makeSignalSource(signal: SIGINT)
        let handler: DispatchWorkItem? = DispatchWorkItem {
            onSignal()
            exit(0)
        }
        signalDispatchSource.setEventHandler(handler: handler!)
        signalDispatchSource.resume()
        return signalDispatchSource
    }
}

protocol IntervalDescription {
    var description: String { get }
    var simpleDescription: String { get }
    func printSimpleDescription() -> Void
}

extension TimeInterval: IntervalDescription {
    var description: String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .brief
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.zeroFormattingBehavior = .pad

        if let result = formatter.string(from: self) {
            return result
        } else {
            return ""
        }
    }

    var simpleDescription: String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.zeroFormattingBehavior = .pad

        if let result = formatter.string(from: self) {
            return result
        } else {
            return ""
        }
    }

    func printSimpleDescription() {
        print("\r", self.description, terminator: "")
        flush_stdout()
    }
}

func flush_stdout() {
    fflush(stdout)
}

let startTime = Date()
var endTime = startTime
let timer = Timer.scheduledTimer(
    withTimeInterval: 1,
    repeats: true
) { (_) -> Void in
    endTime = Date()
    let interval = endTime.timeIntervalSince(startTime)
    interval.printSimpleDescription()
}

let signalDispatchSource = GCD.install {
    let interval = endTime.timeIntervalSince(startTime)
    interval.printSimpleDescription()
    print("\nBye!")
}

print("Starting.")
timer.fire()
RunLoop.main.run()