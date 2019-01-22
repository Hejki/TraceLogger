// Copyright (c) 2019 Hejki

#if os(Linux)

    @testable import TraceLoggerTests
    import XCTest

    XCTMain([
        testCase(CombineLoggerTests.allTests),
        testCase(ConsoleWriterTests.allTests),
        testCase(LogAppenderTests.allTests),
        testCase(FileWriterTests.allTests),
    ])

#endif
