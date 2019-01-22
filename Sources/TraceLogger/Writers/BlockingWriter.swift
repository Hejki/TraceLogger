// Copyright (c) 2019 Hejki

import Foundation

public class BlockingWriter: LogWriter {
    private let mutex: Mutex

    init() {
        self.mutex = Mutex(.normal)
    }

    public final func log(message: String) {
        mutex.lock()
        safeWrite(message)
        mutex.unlock()
    }

    open func safeWrite(_ message: String) {
        fatalError("Subclass must override this method")
    }
}
