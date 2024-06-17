//
//  File.swift
//  
//
//  Created by bro on 2023/2/7.
//

import Foundation
import Logging

// MARK: - MetadataValue
extension Logger.MetadataValue {
    public static func bool(_ value: Bool) -> Self {
        self.string("\(value)")
    }
    public static func integer(_ value: IntegerLiteralType) -> Self {
        self.string("\(value)")
    }
    public static func float(_ value: FloatLiteralType) -> Self {
        self.string("\(value)")
    }
    public static func `nil`() -> Self {
        self.string("nil")
    }
    public static func `optional`<V>(_ value: Optional<V>) -> Self {
        switch value {
        case .none:
            return self.string("nil")
        case .some(let wrappedValue):
            return self.string("\(wrappedValue)")
        }
    }
}
extension Logger.MetadataValue: @retroactive ExpressibleByBooleanLiteral {
    public init(booleanLiteral value: BooleanLiteralType) {
        self = .bool(value)
    }
}
extension Logger.MetadataValue: @retroactive ExpressibleByIntegerLiteral {
    public init(integerLiteral value: IntegerLiteralType) {
        self = .integer(value)
    }
}
extension Logger.MetadataValue: @retroactive ExpressibleByFloatLiteral {
    public init(floatLiteral value: FloatLiteralType) {
        self = .float(value)
    }
}
extension Logger.MetadataValue: @retroactive ExpressibleByNilLiteral {
    public init(nilLiteral: ()) {
        self = .nil()
    }
}

// MARK: - Report error
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
