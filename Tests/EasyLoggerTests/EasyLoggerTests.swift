import XCTest
@testable import EasyLogger
import Logging

final class EasyLoggerTests: XCTestCase {
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        
        WriteOutputConfigure.default.maximumStorageTime = 200
        
        LoggingSystem.bootstrap { value in
            return EasyLogger(label: value, logLevel: .trace, outputs:  { label, level in
                [
                    DefaultOutput(label: label, level: level),
                    ConsoleOutput(label: label, level: level),
                    WriteOutput(level: .trace)
                ]
            })
        }
        
        // output
        var logger = Logger(label: "test-console-output")
        logger[metadataKey: "isOpen1"] = .bool(true)
        logger.info("yes", metadata: ["abc": "1", "isOpen": true, "price": 1.0, "int": 10, "isNil": nil])
        logger.error("test happend error")
        logger.warning("test warning")
        logger.info("test info")
    }
}
