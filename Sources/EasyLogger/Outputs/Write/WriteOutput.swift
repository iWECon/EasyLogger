//
//  File.swift
//  
//
//  Created by bro on 2023/2/7.
//

import Foundation
import Logging

extension URL {
    
    func outputPath(percentEncoded: Bool = true) -> String {
        if #available(iOS 16.0, *) {
            return self.path(percentEncoded: percentEncoded)
        }
        return self.path
    }
}


/// Write output to local. Related configuration is in `WriteOutputConfigure`.
public struct WriteOutput: Output {
    public private(set) var label: String
    public private(set) var level: Logging.Logger.Level
    private let stream: TextOutputStream?
    
    public init(level: Logging.Logger.Level, stream: TextOutputStream) {
        self.label = "write-output"
        self.level = level
        self.stream = stream
    }
    
    public init(level: Logging.Logger.Level) {
        self.label = "write-output"
        self.level = level
        
        WriteOutputConfigure.default.detectOldLogFilesAndDelete()
        
        do {
            let fileHandle = try FileHandle(forWritingTo: WriteOutputConfigure.default.currentLogFilePath)
            self.stream = try WriteFileStream(fileHandle: fileHandle)
        } catch {
            self.stream = nil
            assertionFailure("[EasyLogger] [WriteOutput] [init] failed: \(error.localizedDescription)")
        }
    }
    
    public func output(label: String, level: Logging.Logger.Level, timestamp: String, message: String) {
        guard let stream else { return }
        guard level.naturalValue >= self.level.naturalValue else { return }
        
        var _stream = stream
        _stream.write("\(timestamp) \(message)\(WriteOutputConfigure.default.delimiter)")
    }
}
