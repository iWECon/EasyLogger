//
//  File.swift
//  
//
//  Created by bro on 2023/2/7.
//

import Foundation
import os
import Logging

fileprivate extension Logging.Logger.Level {
    var osLogType: OSLogType {
        switch self {
        case .trace:
            return OSLogType.default
        case .debug:
            return OSLogType.debug
        case .info:
            return OSLogType.info
        case .notice:
            return OSLogType.info
        case .warning:
            return OSLogType.info
        case .error:
            return OSLogType.error
        case .critical:
            return OSLogType.fault
        }
    }
}

public struct ConsoleOutput: Output {
    
    public var label: String
    public var level: Logging.Logger.Level
    
    let osLog: OSLog
    
    public init(label: String, level: Logging.Logger.Level) {
        self.label = label
        self.level = level
        self.osLog = OSLog(subsystem: Bundle.main.bundleIdentifier ?? "in.iiiam.logger", category: label)
    }
    
    public func output(label: String, level: Logging.Logger.Level, timestamp: String, message: String) {
        guard level.naturalValue >= self.level.naturalValue else { return }
        os_log("%s", log: osLog, type: level.osLogType, "\(timestamp) \(message)")
    }
}
