// Copyright (c) 2019 Hejki

import Logging

/// Extend Logger protocol for method with message formater and tag.
public protocol TraceLogger: Logger {

    /// Return current active log level
    var level: LogLevel { get }

    var isVerboseEnabled: Bool { get }
    var isDebugEnabled: Bool { get }
    var isInfoEnabled: Bool { get }
    var isWarningEnabled: Bool { get }
    var isErrorEnabled: Bool { get }
    var isFatalEnabled: Bool { get }

    func log(format: String, parameters: [CVarArg], at level: LogLevel, file: String, function: String, line: UInt, column: UInt)
}

public extension TraceLogger {

    public var isVerboseEnabled: Bool {
        return level <= .verbose
    }

    public var isDebugEnabled: Bool {
        return level <= .debug
    }

    public var isInfoEnabled: Bool {
        return level <= .info
    }

    public var isWarningEnabled: Bool {
        return level <= .warning
    }

    public var isErrorEnabled: Bool {
        return level <= .error
    }

    public var isFatalEnabled: Bool {
        return level <= .fatal
    }

    /// Verbose logs are used to log tiny, usually irrelevant information.
    /// They are helpful when tracing specific lines of code and their results
    public func verbose(_ format: String, file: String = #file, function: String = #function, line: UInt = #line, column: UInt = #column, _ parameters: CVarArg...) {
        self.log(format: format, parameters: parameters, at: .verbose, file: file, function: function, line: line, column: column)
    }

    /// Debug logs are used to debug problems
    public func debug(_ format: String, file: String = #file, function: String = #function, line: UInt = #line, column: UInt = #column, _ parameters: CVarArg...) {
        self.log(format: format, parameters: parameters, at: .debug, file: file, function: function, line: line, column: column)
    }

    /// Info logs are used to indicate a specific infrequent event occurring.
    public func info(_ format: String, file: String = #file, function: String = #function, line: UInt = #line, column: UInt = #column, _ parameters: CVarArg...) {
        self.log(format: format, parameters: parameters, at: .info, file: file, function: function, line: line, column: column)
    }

    /// Warnings are used to indicate something should be fixed but may not have to be solved yet
    public func warning(_ format: String, file: String = #file, function: String = #function, line: UInt = #line, column: UInt = #column, _ parameters: CVarArg...) {
        self.log(format: format, parameters: parameters, at: .warning, file: file, function: function, line: line, column: column)
    }

    /// Error, indicates something went wrong and a part of the execution was failed.
    public func error(t_ format: String, file: String = #file, function: String = #function, line: UInt = #line, column: UInt = #column, _ parameters: CVarArg...) {
        self.log(format: format, parameters: parameters, at: .error, file: file, function: function, line: line, column: column)
    }

    /// Fatal errors/crashes, execution should/must be cancelled.
    public func fatal(_ format: String, file: String = #file, function: String = #function, line: UInt = #line, column: UInt = #column, _ parameters: CVarArg...) {
        self.log(format: format, parameters: parameters, at: .fatal, file: file, function: function, line: line, column: column)
    }
}
