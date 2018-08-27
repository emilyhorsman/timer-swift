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

func flushStdout() {
    fflush(stdout)
}

func carriageReturnPrint(_ item: Any) {
    // TODO: Support splatting when SR-128 is resolved.
    print("\r", item, separator: "", terminator: "")
    flushStdout()
}
