// Copyright (c) 2019 Hejki

import Logging
@testable import TraceLogger
import XCTest

final class CombineLoggerTests: XCTestCase {

    func testLevel() throws {
        var cfg = LoggerConfig(dateGenerator: { Date(timeIntervalSince1970: 12343.123) })
        let infoAppender = AppenderMock(.info)
        let fatalAppender = AppenderMock(.fatal)

        cfg.add(appender: infoAppender)
        cfg.add(appender: fatalAppender)

        let logger = CombineLogger(cfg)

        logger.verbose("v")
        logger.debug("d")
        logger.info("i")
        logger.warning("w")
        logger.error("e")
        logger.fatal("f")

        XCTAssertEqual(infoAppender.buffer.count, 4)
        XCTAssertEqual(infoAppender.buffer[0].message, "i")
        XCTAssertEqual(infoAppender.buffer[1].message, "w")
        XCTAssertEqual(infoAppender.buffer[2].message, "e")
        XCTAssertEqual(infoAppender.buffer[3].message, "f")
        XCTAssertEqual(fatalAppender.buffer.count, 1)
        XCTAssertEqual(fatalAppender.buffer[0].message, "f")
        XCTAssertEqual(logger.level, .info)
        XCTAssertFalse(logger.isVerboseEnabled)
        XCTAssertFalse(logger.isDebugEnabled)
        XCTAssertTrue(logger.isInfoEnabled)
        XCTAssertTrue(logger.isWarningEnabled)
        XCTAssertTrue(logger.isErrorEnabled)
        XCTAssertTrue(logger.isFatalEnabled)
    }

    func testFormat() throws {
        var cfg = LoggerConfig(dateGenerator: { Date(timeIntervalSince1970: 12343.123) })
        let appender = AppenderMock(.info)

        cfg.add(appender: appender)

        let logger = CombineLogger(cfg)

        logger.info("Hello {}", "world")

        XCTAssertEqual(appender.buffer.count, 1)
        XCTAssertEqual(appender.buffer[0].message, "Hello world")
    }

    private class AppenderMock: LogAppender {
        var buffer = [LogContext]()

        init(_ logLevel: LogLevel) {
            super.init(pattern: "%msg", logLevel: logLevel, writers: [])
        }

        override func writeLog(_ log: LogContext) {
            buffer.append(log)
        }
    }

    static var allTests = [
        ("testLevel", testLevel),
        ("testFormat", testFormat),
    ]
}
