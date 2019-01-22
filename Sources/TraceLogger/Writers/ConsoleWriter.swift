// Copyright (c) 2019 Hejki

import Foundation

public class ConsoleWriter: BlockingWriter {
    private var output: FileHandle

    public convenience override init() {
        self.init(output: .standardOutput)
    }

    internal init(output: FileHandle) {
        self.output = output
    }

    open override func safeWrite(_ message: String) {
        output.write(Data(message.utf8))
    }
}
