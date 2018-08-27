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

protocol HumanDescription {
    /**
     * Description for human-readable output on the CLI. Should be formatted in
     * such a way that one can quickly glance at the current running duration.
     */
    var simpleDescription: String { get }
}

protocol MachineDescription {
    /**
     * Description for machine-readable output such as in a CSV/spreadsheet of
     * timer usages.
     */
    var description: String { get }
}

extension TimeInterval: HumanDescription {
    var simpleDescription: String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.zeroFormattingBehavior = .pad

        return formatter.string(from: self) ?? ""
    }
}

extension TimeInterval: MachineDescription {
    var description: String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .brief
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.zeroFormattingBehavior = .pad

        return formatter.string(from: self) ?? ""
    }
}

func flushStdout() {
    fflush(stdout)
}

func carriageReturnPrint(_ item: Any) {
    // TODO: Support splatting when SR-128 is resolved.
    print("\r", item, terminator: "")
    flushStdout()
}

let startTime = Date()
var endTime = startTime
let timer = Timer.scheduledTimer(
    withTimeInterval: 1,
    repeats: true
) { (_) -> Void in
    endTime = Date()
    let interval = endTime.timeIntervalSince(startTime)
    carriageReturnPrint(interval.simpleDescription)
}

let signalDispatchSource = GCD.install {
    let interval = endTime.timeIntervalSince(startTime)
    carriageReturnPrint(interval.simpleDescription)
    print("\nBye!")
}

print("Starting.")
timer.fire()
RunLoop.main.run()