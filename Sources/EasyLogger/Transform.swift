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

public protocol AssemblyMessage {
    
    static func assembly(
        label: String, level: String,
        message: Logging.Logger.Message,
        metadataDescribe: String?,
        source: String, file: String, function: String, line: UInt
    ) -> String
}

public struct DefaultAssemblyMessage: AssemblyMessage {
    public static func assembly(
        label: String, level: String,
        message: Logging.Logger.Message,
        metadataDescribe: String?,
        source: String, file: String, function: String, line: UInt) -> String
    {
        let fileName: String
        if #available(iOS 16.0, *) {
            fileName = URL(filePath: file).lastPathComponent
        } else {
            fileName = URL(fileURLWithPath: file).lastPathComponent
        }
        
        let extraInfo = " { Module: \(source), Track: \(fileName):\(line) > \(function) }"
        return "[\(level.uppercased())] > \(message) < [\(label)]\(metadataDescribe.map { " \($0)" } ?? "")\(extraInfo)"
    }
}

public struct DefaultTransform: Transform {
    
    @usableFromInline
    let label: String
    
    let assemblyMessage: AssemblyMessage.Type
    
    public init(label: String, assemblyMessage: AssemblyMessage.Type = DefaultAssemblyMessage.self) {
        self.label = label
        self.assemblyMessage = assemblyMessage
    }
    
    public func transform(level: Logger.Level, message: Logging.Logger.Message, metadata: Logger.Metadata?, source: String, file: String, function: String, line: UInt) -> String {
        let metadataDescribe = self.prettyMetadata(metadata)
        return assemblyMessage.assembly(
            label: label,
            level: level.rawValue,
            message: message,
            metadataDescribe: metadataDescribe,
            source: source, file: file, function: function, line: line
        )
    }
    
    internal func prettyMetadata(_ metadata: Logging.Logger.Metadata?) -> String? {
        guard let metadata, !metadata.isEmpty else { return nil }
        let value = metadata.lazy.sorted(by: { $0.key < $1.key }).map { "\($0)=\($1)" }.joined(separator: ", ")
        return "[\(value)]"
    }
}
