// Copyright (c) 2019 Hejki

@testable import TraceLogger
// Copyright (c) 2019 Hejki
import XCTest

final class ConsoleWriterTests: XCTestCase {
    let fm = FileManager.default
    let testFile = "/tmp/testConsoleWriterTests"
    var handle: FileHandle!

    override func setUp() {
        try? fm.removeItem(atPath: testFile)
        fm.createFile(atPath: testFile, contents: nil, attributes: nil)

        handle = FileHandle(forUpdatingAtPath: testFile)
    }

    override func tearDown() {
        try? fm.removeItem(atPath: testFile)
    }

    func testWrite() throws {
        let writer = ConsoleWriter(output: handle)

        writer.log(message: "Hello World!")
        writer.log(message: "Another\n")
        writer.log(message: "World")
        handle.seek(toFileOffset: 0)

        XCTAssertEqual(handle.readDataToEndOfFile(), "Hello World!Another\nWorld".data(using: .utf8))
    }

    static var allTests = [
        ("testWrite", testWrite),
    ]
}
