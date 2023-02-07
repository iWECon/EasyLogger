//
//  File.swift
//  
//
//  Created by bro on 2023/2/7.
//

import Foundation
import Logging

extension Logger {
    
    public func report(
        error: @autoclosure () -> Swift.Error,
        metadata: @autoclosure () -> Logging.Logger.Metadata? = nil,
        source: @autoclosure () -> String? = nil,
        file: String = #fileID, function: String = #function, line: UInt = #line
    ) {
        self.error(
            "\(error().localizedDescription)", metadata: metadata(),
            source: source(), file: file, function: function, line: line
        )
    }
}

extension Logging.Logger.Level {
    var naturalValue: Int {
        switch self {
        case .trace:
            return 0
        case .debug:
            return 1
        case .info:
            return 2
        case .notice:
            return 3
        case .warning:
            return 4
        case .error:
            return 5
        case .critical:
            return 6
        }
    }
}

open class SendableOperationQueue: OperationQueue, @unchecked Sendable { }
