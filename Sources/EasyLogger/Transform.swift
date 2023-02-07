//
//  File.swift
//  
//
//  Created by i on 2023/2/7.
//

import Foundation
import Logging

public protocol Transform {
    
    func transform(
        level: Logging.Logger.Level,
        message: Logging.Logger.Message,
        metadata: Logging.Logger.Metadata?,
        source: String, file: String, function: String, line: UInt
    ) -> String
}

public struct DefaultTransform: Transform {
    
    @usableFromInline
    let label: String
    
    public init(label: String) {
        self.label = label
    }
    
    public func transform(level: Logger.Level, message: Logging.Logger.Message, metadata: Logger.Metadata?, source: String, file: String, function: String, line: UInt) -> String {
        
        let fileName: String
        if #available(iOS 16.0, *) {
            fileName = URL(filePath: file).lastPathComponent
        } else {
            fileName = URL(fileURLWithPath: file).lastPathComponent
        }
        
        let metadataDescribe = self.prettyMetadata(metadata)
        let extraInfo = " { SOURCE: \(source), TRACK: \(fileName):\(line) > \(function) }"
        return "[\(level.rawValue.uppercased())] [\(label)] > \(message) <\(metadataDescribe.map { " \($0)" } ?? "")\(extraInfo)"
    }
    
    internal func prettyMetadata(_ metadata: Logging.Logger.Metadata?) -> String? {
        guard let metadata, !metadata.isEmpty else { return nil }
        let value = metadata.lazy.sorted(by: { $0.key < $1.key }).map { "\($0)=\($1)" }.joined(separator: ", ")
        return "[\(value)]"
    }
}
