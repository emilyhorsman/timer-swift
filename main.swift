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

func flushStdout() {
    fflush(stdout)
}

func carriageReturnPrint(_ item: Any) {
    // TODO: Support splatting when SR-128 is resolved.
    print("\r", item, terminator: "")
    flushStdout()
}

class AppTimer {
    let startTime = Date()

    func tick() {
        carriageReturnPrint(HumanDateComponentsFormatter.string(from: self.interval) ?? "")
    }

    var interval: TimeInterval {
        return self.startTime.timeIntervalSinceNow
    }
}

let appTimer = AppTimer()
let timer = Timer.scheduledTimer(
    withTimeInterval: 1,
    repeats: true
) { (_: Timer) -> Void in
    appTimer.tick()
}

let signalDispatchSource = GCD.install {
    appTimer.tick()
    print("\nBye!")
}

print("Starting.")
timer.fire()
RunLoop.main.run()