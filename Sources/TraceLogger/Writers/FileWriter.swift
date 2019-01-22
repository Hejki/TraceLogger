// Copyright (c) 2019 Hejki

import Foundation

public class FileWriter: BlockingWriter {
    private let url: URL
    private let encoding: String.Encoding
    private let maxFileSize: UInt64
    private let maxArchiveFileCount: UInt
    private var fileHandle: FileHandle?

    public enum Error: Swift.Error, CustomStringConvertible {
        case fileCreateFailed(String)
        case fileNotExist(String)
        case fileSizeNotCovertible(String)

        public var description: String {
            switch self {
            case let .fileCreateFailed(path):
                return "Failed to create a log file at: \(path)"
            case let .fileNotExist(path):
                return "Failed to archive, file does not exist: \(path)"
            case let .fileSizeNotCovertible(value):
                return "Cannot convert value \(value) to file size. Expected format is (\\d+)[BKM]?"
            }
        }
    }

    public struct FileSize: ExpressibleByIntegerLiteral {
        public typealias IntegerLiteralType = UInt64
        internal let size: UInt64

        public init(bytes size: UInt64) {
            self.size = size
        }

        public init(integerLiteral value: UInt64) {
            self.size = value
        }

        public init(kiloBytes size: UInt64) {
            self.init(bytes: size * 1024)
        }

        public init(megaBytes size: UInt64) {
            self.init(kiloBytes: size * 1024)
        }

        public init(_ string: String) throws {
            guard let value = UInt64(string.dropLast()) else {
                throw Error.fileSizeNotCovertible(string)
            }

            switch string.suffix(1) {
            case "b", "B":
                self.init(bytes: value)
            case "k", "K":
                self.init(kiloBytes: value)
            case "m", "M":
                self.init(megaBytes: value)
            default:
                throw Error.fileSizeNotCovertible(string)
            }
        }
    }

    public init(
        directory: String,
        fileName: String,
        encoding: String.Encoding = .utf8,
        maxFileSize: FileSize = FileSize(megaBytes: 10),
        maxArchiveFileCount: Int = 100
    ) throws {
        self.url = URL(fileURLWithPath: directory, isDirectory: true).appendingPathComponent(fileName)
        self.encoding = encoding
        self.maxFileSize = maxFileSize.size
        self.maxArchiveFileCount = UInt(maxArchiveFileCount)

        super.init()
        self.fileHandle = try open()
    }

    deinit {
        closeLogFile()
    }

    open override func safeWrite(_ message: String) {
        guard let fileHandle = fileHandle,
            let data = message.data(using: encoding) else {
            return
        }

        fileHandle.write(data)

        if fileHandle.offsetInFile >= maxFileSize {
            rotateLogFile()
        }
    }

    /// Rotate the log file.
    private func rotateLogFile() {
        closeLogFile()

        // Archive
        do {
            try archive(url: url, index: 1)
        } catch {
            FileHandle.standardError.write(Data("\(error)\n".utf8))
        }

        do {
            self.fileHandle = try open()
        } catch {
            self.fileHandle = nil
            FileHandle.standardError.write(Data("\(error)\n".utf8))
        }
    }

    private func archive(url: URL, index: Int) throws {
        let fileManager = FileManager.default

        guard fileManager.fileExists(atPath: url.path) else {
            throw FileWriter.Error.fileNotExist(url.absoluteString)
        }

        let archiveFileUrl = url
            .deletingPathExtension()
            .appendingPathExtension(index == 1 ? "log.\(index)" : "\(index)")

        if fileManager.fileExists(atPath: archiveFileUrl.path) {
            if index >= maxArchiveFileCount {
                try fileManager.removeItem(at: archiveFileUrl)
            } else {
                try archive(url: archiveFileUrl, index: index + 1)
            }
        }

        try fileManager.moveItem(at: url, to: archiveFileUrl)
    }

    /// Flushes and closed the log file handle.
    private func closeLogFile() {
        fileHandle?.synchronizeFile()
        fileHandle?.closeFile()
    }

    /// Opens the log file, if not exist then create it.
    ///
    /// - returns: FileHandle to opened file
    private func open() throws -> FileHandle {
        let fileManager = FileManager.default

        if !fileManager.fileExists(atPath: url.path) {
            try fileManager.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: nil)

            guard fileManager.createFile(atPath: url.path, contents: nil, attributes: nil) else {
                throw FileWriter.Error.fileCreateFailed(url.absoluteString)
            }
        }

        let fileHandle = try FileHandle(forWritingTo: url)

        fileHandle.seekToEndOfFile()
        return fileHandle
    }
}
