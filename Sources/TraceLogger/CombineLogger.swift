// Copyright (c) 2019 Hejki

import Logging
import Service

public class CombineLogger: Logger, TraceLogger, Service {
    private let config: LoggerConfig
    public let level: LogLevel

    internal init(_ config: LoggerConfig) {
        self.config = config
        self.level = config.appenders.map { $0.logLevel }
            .sorted(by: <)
            .first!
    }

    public func log(_ string: String, at level: LogLevel, file: String, function: String, line: UInt, column: UInt) {
        let timestamp = config.dateGenerator() // Capture the timestamp as early as possible to get the most accruate time.
        let appenders = config.appenders.filter { $0.isAvailable(for: level) }

        if !appenders.isEmpty {
            writeLog(
                LogContext(date: timestamp, level: level, file: file,
                           function: function, line: line, column: column, message: string),
                to: appenders
            )
        }
    }

    public func log(format: String, parameters: [CustomStringConvertible], at level: LogLevel, file: String, function: String, line: UInt, column: UInt) {
        let timestamp = config.dateGenerator() // Capture the timestamp as early as possible to get the most accruate time.
        let appenders = config.appenders.filter { $0.isAvailable(for: level) }

        if !appenders.isEmpty {
            #if os(Linux)
                let strFormat = format.replacingOccurrences(of: "{}", with: "%s")
                let strArgs = parameters.map { $0.description.cString }
            #else
                let strFormat = format.replacingOccurrences(of: "{}", with: "%@")
                let strArgs = parameters.map { $0.description }
            #endif

            let message = String(format: strFormat, arguments: strArgs)

            writeLog(
                LogContext(date: timestamp, level: level, file: file,
                           function: function, line: line, column: column, message: message),
                to: appenders
            )
        }
    }

    @inline(__always)
    private func writeLog(_ log: LogContext, to appenders: [LogAppender]) {
        appenders.forEach { $0.writeLog(log) }
    }
}

public struct LoggerConfig: Service {
    fileprivate var appenders: [LogAppender]
    fileprivate let dateGenerator: () -> Date

    public init(dateGenerator: @escaping () -> Date = Date.init) {
        self.appenders = []
        self.dateGenerator = dateGenerator
    }

    public mutating func add(appender: LogAppender) {
        self.appenders.append(appender)
    }

    internal static var `default`: LoggerConfig {
        var conf = LoggerConfig()

        conf.add(appender: LogAppender(
            pattern: "%date{HH:mm:ss.SSS} %level %file[%line] - %msg%n",
            logLevel: .debug,
            writer: ConsoleWriter()
        ))
        return conf
    }
}

/// Extend LogLevel to Comparable entity
extension LogLevel: Comparable {

    public static func < (lhs: LogLevel, rhs: LogLevel) -> Bool {
        if lhs == rhs {
            return false
        }

        switch lhs {
        case .verbose:
            return true
        case .debug:
            return rhs != .verbose
        case .info:
            return rhs != .verbose && rhs != .debug
        case .warning:
            return rhs == .error || rhs == .fatal
        case .error:
            return rhs == .fatal
        default:
            return false
        }
    }

    public static func == (lhs: LogLevel, rhs: LogLevel) -> Bool {
        switch (lhs, rhs) {
        case (.verbose, .verbose): return true
        case (.debug, .debug): return true
        case (.info, .info): return true
        case (.warning, .warning): return true
        case (.error, .error): return true
        case (.fatal, .fatal): return true
        case let (.custom(lhv), .custom(rhv)): return lhv == rhv
        default: return false
        }
    }
}
