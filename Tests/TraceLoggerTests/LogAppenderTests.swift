// Copyright (c) 2019 Hejki

import Logging
// import Service
@testable import TraceLogger
// Copyright (c) 2019 Hejki
import XCTest
// import class Foundation.Bundle

final class LogAppenderTests: XCTestCase {

    func testParser() throws {
        let writer = WriterMock()
        let appender = LogAppender(
            pattern: "%date{HH:mm:ss.SSS} %level %file.%fext[%line:%column] - %msg%n",
            logLevel: .info,
            writer: writer
        )

        appender.writeLog(logContext(level: .error, msg: "This is error"))

        XCTAssertEqual(appender.pattern, "%date{HH:mm:ss.SSS} %level %file.%fext[%line:%column] - %msg%n")
        XCTAssertEqual(writer.buffer.count, 1)
        XCTAssertEqual(writer.buffer[0], "04:25:43.123 ERROR LogAppenderTests.swift[18:24] - This is error\n")
    }

    func testLogLevel() throws {
        let writer = WriterMock()
        let appender = LogAppender(pattern: "%level %msg", logLevel: .verbose, writer: writer)

        appender.writeLog(logContext(level: .verbose, msg: "v"))
        appender.writeLog(logContext(level: .debug, msg: "d"))
        appender.writeLog(logContext(level: .info, msg: "i"))
        appender.writeLog(logContext(level: .warning, msg: "w"))
        appender.writeLog(logContext(level: .error, msg: "e"))
        appender.writeLog(logContext(level: .fatal, msg: "f"))

        XCTAssertEqual(writer.buffer, ["TRACE v", "DEBUG d", "INFO  i", "WARN  w", "ERROR e", "FATAL f"])
    }

    func testLogLevelVerbose() throws {
        let appender = LogAppender(pattern: "", logLevel: .verbose, writers: [])

        XCTAssertTrue(appender.isAvailable(for: .verbose))
        XCTAssertTrue(appender.isAvailable(for: .debug))
        XCTAssertTrue(appender.isAvailable(for: .info))
        XCTAssertTrue(appender.isAvailable(for: .warning))
        XCTAssertTrue(appender.isAvailable(for: .error))
        XCTAssertTrue(appender.isAvailable(for: .fatal))
    }

    func testLogLevelDebug() throws {
        let appender = LogAppender(pattern: "", logLevel: .debug, writers: [])

        XCTAssertFalse(appender.isAvailable(for: .verbose))
        XCTAssertTrue(appender.isAvailable(for: .debug))
        XCTAssertTrue(appender.isAvailable(for: .info))
        XCTAssertTrue(appender.isAvailable(for: .warning))
        XCTAssertTrue(appender.isAvailable(for: .error))
        XCTAssertTrue(appender.isAvailable(for: .fatal))
    }

    func testLogLevelInfo() throws {
        let appender = LogAppender(pattern: "", logLevel: .info, writers: [])

        XCTAssertFalse(appender.isAvailable(for: .verbose))
        XCTAssertFalse(appender.isAvailable(for: .debug))
        XCTAssertTrue(appender.isAvailable(for: .info))
        XCTAssertTrue(appender.isAvailable(for: .warning))
        XCTAssertTrue(appender.isAvailable(for: .error))
        XCTAssertTrue(appender.isAvailable(for: .fatal))
    }

    func testLogLevelWarning() throws {
        let appender = LogAppender(pattern: "", logLevel: .warning, writers: [])

        XCTAssertFalse(appender.isAvailable(for: .verbose))
        XCTAssertFalse(appender.isAvailable(for: .debug))
        XCTAssertFalse(appender.isAvailable(for: .info))
        XCTAssertTrue(appender.isAvailable(for: .warning))
        XCTAssertTrue(appender.isAvailable(for: .error))
        XCTAssertTrue(appender.isAvailable(for: .fatal))
    }

    func testLogLevelError() throws {
        let appender = LogAppender(pattern: "", logLevel: .error, writers: [])

        XCTAssertFalse(appender.isAvailable(for: .verbose))
        XCTAssertFalse(appender.isAvailable(for: .debug))
        XCTAssertFalse(appender.isAvailable(for: .info))
        XCTAssertFalse(appender.isAvailable(for: .warning))
        XCTAssertTrue(appender.isAvailable(for: .error))
        XCTAssertTrue(appender.isAvailable(for: .fatal))
    }

    func testLogLevelFatal() throws {
        let appender = LogAppender(pattern: "", logLevel: .fatal, writers: [])

        XCTAssertFalse(appender.isAvailable(for: .verbose))
        XCTAssertFalse(appender.isAvailable(for: .debug))
        XCTAssertFalse(appender.isAvailable(for: .info))
        XCTAssertFalse(appender.isAvailable(for: .warning))
        XCTAssertFalse(appender.isAvailable(for: .error))
        XCTAssertTrue(appender.isAvailable(for: .fatal))
    }

    func testParseDate() throws {
        let writer = WriterMock()
        let appender = LogAppender(pattern: "%date{yyyy-MM-dd'T'HH:mm:ss.SSS Z}", logLevel: .info, writer: writer)

        appender.writeLog(logContext(level: .info, msg: ""))

        XCTAssertEqual(appender.pattern, "%date{yyyy-MM-dd'T'HH:mm:ss.SSS Z}")
        XCTAssertEqual(writer.buffer, ["1970-01-01T04:25:43.123 +0100"])
    }

    func testParseDateWithoutFormat() throws {
        let writer = WriterMock()
        let appender = LogAppender(pattern: "%date", logLevel: .info, writer: writer)

        appender.writeLog(logContext(level: .info, msg: ""))

        XCTAssertEqual(appender.pattern, "%date{yyyy-MM-dd HH:mm:ss.SSS}")
        XCTAssertEqual(writer.buffer, ["1970-01-01 04:25:43.123"])
    }

    private func logContext(level: LogLevel, msg: String) -> LogContext {
        return LogContext(
            date: Date(timeIntervalSince1970: 12343.123),
            level: level,
            file: #file,
            function: #function,
            line: 18,
            column: 24,
            message: msg
        )
    }

    private class WriterMock: LogWriter {
        var buffer = [String]()

        func log(message: String) {
            buffer.append(message)
        }
    }

    static var allTests = [
        ("testParser", testParser),
        ("testLogLevel", testLogLevel),
        ("testLogLevelVerbose", testLogLevelVerbose),
        ("testLogLevelDebug", testLogLevelDebug),
        ("testLogLevelInfo", testLogLevelInfo),
        ("testLogLevelWarning", testLogLevelWarning),
        ("testLogLevelError", testLogLevelError),
        ("testLogLevelFatal", testLogLevelFatal),
        ("testParseDate", testParseDate),
        ("testParseDateWithoutFormat", testParseDateWithoutFormat),
    ]
}
