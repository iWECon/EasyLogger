import XCTest
@testable import EasyLogger
import Logging

final class EasyLoggerTests: XCTestCase {
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        
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
        let logger = Logger(label: "test-console-output")
        logger.info("yes", metadata: ["abc": "1", "isOpen": true, "price": 1.0, "int": 10, "isNil": nil])
        logger.error("test happend error")
        logger.warning("test warning")
        logger.info("test info")
    }
}
