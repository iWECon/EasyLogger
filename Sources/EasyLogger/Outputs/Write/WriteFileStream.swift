//
//  File.swift
//  
//
//  Created by bro on 2023/2/8.
//

import Foundation

public struct WriteFileStream: TextOutputStream {
    
    private let fileHandle: FileHandle
    private let encoding: String.Encoding
    
    public init(fileHandle: FileHandle, encoding: String.Encoding = .utf8) throws {
        self.fileHandle = fileHandle
        if #available(iOS 13.4, *) {
            try fileHandle.seekToEnd()
        } else {
            fileHandle.seekToEndOfFile()
        }
        self.encoding = encoding
    }
    
    public mutating func write(_ string: String) {
        guard let data = string.data(using: encoding) else {
            return
        }
        
        if #available(iOS 13.4, *) {
            do {
                try fileHandle.write(contentsOf: data)
            } catch {
                print("[WriteFileStream] [write] failed: \(error.localizedDescription)")
            }
        } else {
            fileHandle.write(data)
        }
    }
}
