//
//  File.swift
//  
//
//  Created by bro on 2023/2/7.
//

import Foundation
import Logging

#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
import Darwin
#elseif os(Windows)
import CRT
#elseif canImport(Glibc)
import Glibc
#elseif canImport(WASILibc)
import WASILibc
#else
#error("Unsupported runtime")
#endif

extension URL {
    
    func outputPath(percentEncoded: Bool = true) -> String {
        if #available(iOS 16.0, *) {
            return self.path(percentEncoded: percentEncoded)
        }
        return self.path
    }
}

/// Write output to local.
public struct WriteOutput: Output {
    
    public var label: String
    public var level: Logging.Logger.Level
    
    public var currentLogName: String
    
    public var localDirectory: URL {
        didSet {
            print("[EasyLogger] [WriteOutput] > Local Directory: \(self.localDirectory.outputPath()), fileName: \(self.currentLogName)")
        }
    }
    public var delimiter: String
    
    /// Create WriteOutput.
    /// - Parameters:
    ///   - label: <#label description#>
    ///   - level: <#level description#>
    ///   - localDirectory: Default is `FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first`.
    ///   - delimiter: Default is `   \n`.
    public init(
        label: String,
        level: Logging.Logger.Level,
        localDirectory: URL? = nil,
        delimiter: String = "   \n")
    {
        self.label = label
        self.level = level
        
        self.delimiter = delimiter
        
        if let localDirectory {
            self.localDirectory = localDirectory
        } else {
            guard let cachesDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
                fatalError("Can't access .cachesDirectory in .userDomainMask")
            }
            
            let subpath = "\(Bundle.main.bundleIdentifier ?? "in.iiiam.logger")/logger-caches"
            if #available(iOS 16.0, *) {
                self.localDirectory = cachesDirectory.appending(path: subpath)
            } else {
                // Fallback on earlier versions
                self.localDirectory = cachesDirectory.appendingPathComponent(subpath)
            }
        }
        
        func nameTimestamp() -> String {
            var buffer = [Int8](repeating: 0, count: 255)
            #if os(Windows)
            var timestamp = __time64_t()
            _ = _time64(&timestamp)

            var localTime = tm()
            _ = _localtime64_s(&localTime, &timestamp)

            _ = strftime(&buffer, buffer.count, "%Y%m%d_%H%M%S", &localTime)
            #else
            var timestamp = time(nil)
            let localTime = localtime(&timestamp)
            strftime(&buffer, buffer.count, "%Y%m%d_%H%M%S", localTime)
            #endif
            return buffer.withUnsafeBufferPointer {
                $0.withMemoryRebound(to: CChar.self) {
                    String(cString: $0.baseAddress!)
                }
            }
        }
        self.currentLogName = "logger-\(nameTimestamp()).log"
        
        print("[EasyLogger] [WriteOutput] > Local Directory: \(self.localDirectory.outputPath()), fileName: \(self.currentLogName)")
    }
    
    public func output(label: String, level: Logging.Logger.Level, timestamp: String, message: String) {
        guard level.naturalValue >= self.level.naturalValue else { return }
        
        let output: String
        if label != self.label {
            let newMessage = message.replacingOccurrences(of: "", with: "")
            output = "\(timestamp) \(newMessage)"
        } else {
            output = "\(timestamp) \(message)"
        }
        
        do {
            try FileManager.default.createDirectory(at: self.localDirectory, withIntermediateDirectories: true)
            
            let fileURL: URL
            if #available(iOS 16.0, *) {
                fileURL = localDirectory.appending(path: self.currentLogName)
            } else {
                // Fallback on earlier versions
                fileURL = localDirectory.appendingPathComponent(self.currentLogName)
            }
            
            if !FileManager.default.fileExists(atPath: fileURL.outputPath()) {
                FileManager.default.createFile(atPath: fileURL.outputPath(), contents: nil)
            }
            
            let fileHandle = try FileHandle(forWritingTo: fileURL)
            if #available(iOS 13.4, *) {
                try fileHandle.seekToEnd()
            } else {
                fileHandle.seekToEndOfFile()
            }
            guard let content = "\(output)\(delimiter)".data(using: .utf8) else {
                if #available(iOS 13.0, *) {
                    try fileHandle.close()
                } else {
                    fileHandle.closeFile()
                }
                return
            }
            
            if #available(iOS 13.4, *) {
                try fileHandle.write(contentsOf: content)
            } else {
                fileHandle.write(content)
            }
            
            if #available(iOS 13.0, *) {
                try fileHandle.close()
            } else {
                fileHandle.closeFile()
            }
        } catch {
            print("[EasyLogger] [WriteOutput] > Write failed: \(error.localizedDescription)")
        }
    }
}
