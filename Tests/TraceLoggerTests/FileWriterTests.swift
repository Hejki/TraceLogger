// Copyright (c) 2019 Hejki

@testable import TraceLogger
// Copyright (c) 2019 Hejki
import XCTest

final class FileWriterTests: XCTestCase {
    let fm = FileManager.default
    let testDir = "/tmp/"
    let testLog = "testFileWriterTests.log"

    override func setUp() {
        removeTestFiles()
    }

    override func tearDown() {
        removeTestFiles()
    }

    func testWrite() throws {
        let writer = try! FileWriter(
            directory: testDir,
            fileName: testLog,
            maxFileSize: 1,
            maxArchiveFileCount: 3
        )

        writer.log(message: "string")
        writer.log(message: "Hello World!")
        writer.log(message: "Another\n")
        writer.log(message: "World")

        XCTAssertEqual(content(".1"), "World")
        XCTAssertEqual(content(".2"), "Another\n")
        XCTAssertEqual(content(".3"), "Hello World!")
        XCTAssertFalse(fm.fileExists(atPath: "\(testDir)\(testLog).4"))
    }

    private func content(_ suffix: String) -> String {
        return try! String(contentsOfFile: testDir + testLog + suffix)
    }

    private func removeTestFiles() {
        ["", ".1", ".2", ".3", ".4"].forEach { suffix in
            try? fm.removeItem(atPath: testDir + testLog + suffix)
        }
    }

    static var allTests = [
        ("testWrite", testWrite),
    ]
}
