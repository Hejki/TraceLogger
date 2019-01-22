// Copyright (c) 2019 Hejki

import Logging

public class LogAppender {
    private let messageTags: [PatternTag]
    private let writers: [LogWriter]
    internal let logLevel: LogLevel

    public var pattern: String {
        return messageTags.map { $0.description }.joined()
    }

    public convenience init(pattern: String, logLevel: LogLevel, writer: LogWriter) {
        self.init(pattern: pattern, logLevel: logLevel, writers: [writer])
    }

    public init(pattern: String, logLevel: LogLevel, writers: [LogWriter]) {
        self.messageTags = LogAppender.parse(pattern)
        self.writers = writers
        self.logLevel = logLevel
    }

    internal func isAvailable(for level: LogLevel) -> Bool {
        return logLevel <= level
    }

    internal func writeLog(_ log: LogContext) {
        let message = messageTags.map { $0.log(log) }.joined()

        writers.forEach { $0.log(message: message) }
    }

    private static func parse(_ pattern: String) -> [PatternTag] {
        var tags = [PatternTag]()
        var characters = [Character](pattern)
        var freeText = ""

        var pos = 0
        while pos < characters.count {

            let currentChar = characters[pos]

            if currentChar == "%" {
                if freeText != "" {
                    tags.append(.string(freeText))
                    freeText = ""
                }

                let tag = parseTag(characters, pos)
                tags.append(tag.tag)
                pos += tag.skip
            } else {
                freeText += String(currentChar)
                pos += 1
            }
        }

        return tags
    }

    private static func parseTag(_ characters: [Character], _ pos: Int) -> (tag: PatternTag, skip: Int) {
        let maxSize = characters.count - pos

        if let parser = LogPatternParser.allParsers.first(where: { $0.canParse(characters, from: pos, remainingCount: maxSize) }) {
            return parser.parse(characters, from: pos)
        }

        return (tag: .string(String(characters[pos])), skip: 1)
    }
}

/// Log line message context
internal struct LogContext {

    /// Log time
    let date: Date

    let level: LogLevel
    let file: String
    let function: String
    let line: UInt
    let column: UInt
    let message: String
}
