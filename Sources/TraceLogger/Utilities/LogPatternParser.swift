// Copyright (c) 2019 Hejki

import Foundation
import Logging

private extension LogLevel {

    var levelLogName: String {
        switch self {
        case let .custom(s): return s.uppercased()
        case .debug: return "DEBUG"
        case .error: return "ERROR"
        case .fatal: return "FATAL"
        case .info: return "INFO "
        case .verbose: return "TRACE"
        case .warning: return "WARN "
        }
    }
}

internal enum PatternTag {
    case date(DateFormatter)
    case level
    case file, fext, line, column
    case message
    case newLine
    case function
    case string(String)

    func log(_ log: LogContext) -> String {
        switch self {
        case let .date(formatter):
            return formatter.string(from: log.date)
        case .level:
            return log.level.levelLogName
        case .file:
            return URL(fileURLWithPath: log.file).deletingPathExtension().lastPathComponent
        case .fext:
            return URL(fileURLWithPath: log.file).pathExtension
        case .line:
            return String(log.line)
        case .column:
            return String(log.column)
        case .message:
            return log.message
        case let .string(text):
            return text
        case .newLine:
            return "\n"
        case .function:
            return log.function
        }
    }
}

extension PatternTag: CustomStringConvertible {

    var description: String {
        switch self {
        case let .date(format): return "%date{\(format.dateFormat ?? "")}"
        case .level: return "%level"
        case .file: return "%file"
        case .fext: return "%fext"
        case .line: return "%line"
        case .column: return "%column"
        case .message: return "%msg"
        case .newLine: return "%n"
        case .function: return "%func"
        case let .string(text): return text
        }
    }
}

internal class LogPatternParser {
    typealias ParserResult = (tag: PatternTag, skip: Int)

    private static var newLine = SimpleLogPatternParser(.newLine)
    private static var message = SimpleLogPatternParser(.message)
    private static var file = SimpleLogPatternParser(.file)
    private static var fext = SimpleLogPatternParser(.fext)
    private static var line = SimpleLogPatternParser(.line)
    private static var level = SimpleLogPatternParser(.level)
    private static var column = SimpleLogPatternParser(.column)
    private static var function = SimpleLogPatternParser(.function)

    private static let date = ParameterizedLogPatternParser("%date") { dateFormat in
        let formatter = DateFormatter()

        formatter.dateFormat = dateFormat ?? "yyyy-MM-dd HH:mm:ss.SSS"
        return .date(formatter)
    }

    internal static let allParsers: [LogPatternParser] = [
        .newLine, .message, .file, .fext, .line, .level, .column, .function, .date,
    ]

    let pattern: String
    let skipCharacters: Int

    init(_ pattern: String) {
        self.pattern = pattern
        self.skipCharacters = pattern.count
    }

    final func canParse(_ characters: [Character], from pos: Int, remainingCount: Int) -> Bool {
        return remainingCount >= skipCharacters && LogPatternParser.peek(characters, pos, skipCharacters) == pattern
    }

    func parse(_ characters: [Character], from pos: Int) -> ParserResult {
        fatalError("Use subclass instead")
    }

    fileprivate static func peek(_ characters: [Character], _ pos: Int, _ len: Int) -> String {
        return String(characters[pos ..< pos + len])
    }
}

internal final class SimpleLogPatternParser: LogPatternParser {
    let patternTag: PatternTag

    init(_ patternTag: PatternTag) {
        self.patternTag = patternTag
        super.init(patternTag.description)
    }

    override func parse(_ characters: [Character], from pos: Int) -> ParserResult {
        return ParserResult(tag: patternTag, skip: skipCharacters)
    }
}

internal final class ParameterizedLogPatternParser: LogPatternParser {
    typealias ParserResultCreator = (String?) -> PatternTag

    let resultCreator: ParserResultCreator

    init(_ pattern: String, _ resultCreator: @escaping ParserResultCreator) {
        self.resultCreator = resultCreator
        super.init(pattern)
    }

    override func parse(_ characters: [Character], from pos: Int) -> ParserResult {
        let paramStartIndex = pos + skipCharacters
        let charactersLeftCount = characters.count - paramStartIndex

        if charactersLeftCount > 2 && LogPatternParser.peek(characters, paramStartIndex, 1) == "{" {
            if let paramEndIndex = characters[paramStartIndex...].firstIndex(of: "}") {
                let paramLen = paramEndIndex - paramStartIndex
                let param = LogPatternParser.peek(characters, paramStartIndex + 1, paramLen - 1)

                return ParserResult(tag: resultCreator(param), skip: skipCharacters + paramLen + 1)
            }
        }

        return ParserResult(tag: resultCreator(nil), skip: skipCharacters)
    }
}
