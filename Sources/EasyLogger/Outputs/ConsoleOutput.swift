//
//  File.swift
//  
//
//  Created by bro on 2023/2/7.
//

import Foundation
import os
import Logging

/**

// rawValue: 0
@available(macOS 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *)
public static let `default`: OSLogType

// rawValue: 1
@available(macOS 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *)
public static let info: OSLogType
 
// rawValue: 2
@available(macOS 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *)
public static let debug: OSLogType

// rawValue: 3
@available(macOS 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *)
public static let error: OSLogType

// rawValue: 4
@available(macOS 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *)
public static let fault: OSLogType
*/

fileprivate extension Logging.Logger.Level {
    var osLogType: OSLogType {
        switch self {
        case .trace:
            return OSLogType.default
        case .debug:
            return OSLogType.info
        case .info, .notice, .warning:
            return OSLogType.debug
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
    
    /// skip send log to `Console.app` when using xcode run app.
    public var disableWhenRunXcode: Bool = true
    
    let osLog: OSLog
    
    public init(label: String, level: Logging.Logger.Level, disableWhenRunXcode: Bool = true, subsystem: String = Bundle.main.bundleIdentifier ?? "in.iiiam.logger") {
        self.label = label
        self.level = level
        self.disableWhenRunXcode = disableWhenRunXcode
        self.osLog = OSLog(subsystem: subsystem, category: label)
    }
    
    public func output(label: String, level: Logging.Logger.Level, timestamp: String, message: String) {
        if disableWhenRunXcode {
            #if !Xcode
            guard level.naturalValue >= self.level.naturalValue else { return }
            os_log("%s", log: osLog, type: level.osLogType, "\(message)")
            #endif
        } else {
            guard level.naturalValue >= self.level.naturalValue else { return }
            os_log("%s", log: osLog, type: level.osLogType, "\(message)")
        }
    }
}
