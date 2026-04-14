//
//  FileLogger.swift
//  PayTracker
//
//  Created by bmtech on 14.04.2026.
//

import Foundation

final class FileLogger {
    
    static let shared = FileLogger()
    
    private let fileURL: URL
    private let queue = DispatchQueue(label: "file.logger.queue", qos: .background)
    
    private init() {
        let fm = FileManager.default
        let docs = fm.urls(for: .documentDirectory, in: .userDomainMask)[0]
        fileURL = docs.appendingPathComponent("app.log")
        
        createFileIfNeeded()
    }
    
    private func createFileIfNeeded() {
        if !FileManager.default.fileExists(atPath: fileURL.path) {
            FileManager.default.createFile(atPath: fileURL.path, contents: nil)
        }
    }
    
    // MARK: - Public
    
    func log(_ message: String) {
        let timestamp = ISO8601DateFormatter().string(from: Date())
        let fullMessage = "[\(timestamp)] \(message)\n"
        
        queue.async {
            self.write(fullMessage)
        }
    }
    
    // MARK: - Write
    
    private func write(_ text: String) {
        guard let data = text.data(using: .utf8) else { return }
        
        if let handle = try? FileHandle(forWritingTo: fileURL) {
            defer { try? handle.close() }
            
            try? handle.seekToEnd()
            try? handle.write(contentsOf: data)
        }
    }
    
    // MARK: - Debug
    
    func readLogs() -> String {
        (try? String(contentsOf: fileURL)) ?? ""
    }
    
    func clear() {
        try? "".write(to: fileURL, atomically: true, encoding: .utf8)
    }
}
