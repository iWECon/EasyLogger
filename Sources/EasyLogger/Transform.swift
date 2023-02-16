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
        baseMetadata: Logging.Logger.Metadata,
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
        return "[\(level.uppercased())] [\(label)] > \(message) <\(metadataDescribe ?? "")\(extraInfo)"
    }
}

public struct DefaultTransform: Transform {
    
    @usableFromInline
    let label: String
    
    let assemblyMessage: AssemblyMessage.Type
    let metadataProvider: Logger.MetadataProvider?
    
    public init(label: String, metadataProvider: Logger.MetadataProvider? = nil, assemblyMessage: AssemblyMessage.Type = DefaultAssemblyMessage.self) {
        self.label = label
        self.assemblyMessage = assemblyMessage
        self.metadataProvider = metadataProvider
    }
    
    public func transform(
        level: Logger.Level,
        message: Logging.Logger.Message,
        baseMetadata: Logger.Metadata,
        metadata: Logger.Metadata?,
        source: String, file: String, function: String, line: UInt
    ) -> String {
        let effectiveMetadata = DefaultTransform.prettyMetadata(base: baseMetadata, provider: self.metadataProvider, explicit: metadata)
        
        let prettyMetadata: String?
        if let effectiveMetadata = effectiveMetadata {
            prettyMetadata = DefaultTransform.prettify(effectiveMetadata)
        } else {
            prettyMetadata = DefaultTransform.prettify(baseMetadata)
        }
        
        return assemblyMessage.assembly(
            label: label,
            level: level.rawValue,
            message: message,
            metadataDescribe: prettyMetadata.map { " \($0)" } ?? "",
            source: source, file: file, function: function, line: line
        )
    }
    
    public static func prettify(_ metadata: Logger.Metadata) -> String? {
        if metadata.isEmpty {
            return nil
        } else {
            let res = metadata.lazy.sorted(by: { $0.key < $1.key }).map { "\($0)=\($1)" }.joined(separator: " ")
            return "[\(res)]"
        }
    }
    
    public static func prettyMetadata(base: Logging.Logger.Metadata, provider: Logger.MetadataProvider?, explicit: Logger.Metadata?) -> Logger.Metadata? {
        var metadata = base

        let provided = provider?.get() ?? [:]

        guard !provided.isEmpty || !((explicit ?? [:]).isEmpty) else {
            // all per-log-statement values are empty
            return nil
        }

        if !provided.isEmpty {
            metadata.merge(provided, uniquingKeysWith: { _, provided in provided })
        }

        if let explicit = explicit, !explicit.isEmpty {
            metadata.merge(explicit, uniquingKeysWith: { _, explicit in explicit })
        }

        return metadata
    }
}
