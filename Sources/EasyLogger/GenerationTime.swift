//
//  File.swift
//  
//
//  Created by i on 2023/2/7.
//

import Foundation

public protocol GenerationTime {
    static func timestamp() -> String
}

public struct DefaultGenerationTime: GenerationTime {
    private init() { }
    
    public static func timestamp() -> String {
        let formatter = DateFormatter()
        #if DEBUG
        formatter.dateFormat = "HH:mm:ss.SSS"
        #else
        formatter.dateFormat = "YYYYMMdd HH:mm:ss.SSS"
        #endif
        return formatter.string(from: Date())
    }
}
