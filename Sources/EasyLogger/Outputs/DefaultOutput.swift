//
//  File.swift
//  
//
//  Created by bro on 2023/2/7.
//

import Foundation
import Logging

/// Output in Debug.
public struct DefaultOutput: Output {
    
    public var label: String
    public var level: Logging.Logger.Level
    
    /// Conditions to control whether logs are output to the xcode console. Default is `true`.
    public var isEnabled = true
    
    public init(label: String, level: Logging.Logger.Level) {
        self.label = label
        self.level = level
    }
    
    public func output(label: String, level: Logging.Logger.Level, timestamp: String, message: String) {
        guard isEnabled else { return }
        guard level.naturalValue >= self.level.naturalValue else { return }
        print("\(timestamp) \(message)")
    }
}
