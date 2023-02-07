//
//  File.swift
//  
//
//  Created by i on 2023/2/7.
//

import Foundation

public protocol GenerationTime {
    func timestamp() -> String
}

public struct DefaultGenerationTime: GenerationTime {
    
    public let dateFormat: String
    public init(dateFormat: String? = nil) {
        if let dateFormat {
            self.dateFormat = dateFormat
        } else {
            #if DEBUG
            self.dateFormat = "[HH:mm:ss.SSS]"
            #else
            self.dateFormat = "[YYYYMMdd HH:mm:ss.SSS]"
            #endif
        }
    }
    
    public func timestamp() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = self.dateFormat
        return "\(formatter.string(from: Date()))"
    }
}
