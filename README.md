# EasyLogger

A description of this package.


Just use `EasyLogger` in bootstrap.
```swift
import Logging // from swift-logs

LoggingSystem.bootstrap { label in 
    EasyLogger(
        label: label, 
        level: .info,
        // operationQueue: OperationQueue? = nil,
        // generationTime: GenerationType.Type = DefaultGenerationTime.self,
        // transform: (_ label: String) -> Transform,
        outputs: { label, level in
            [
            DefaultOutput(label: label, level: level),
            WriteOutput(label: "write", level: .error)
            ]
        }
    )
}

let logger = Logger(label: "network", level)
logger.trace("network response") // will not output
logger.info("info response") // will not output
logger.error("error") // output and write to local file
logger.report(error: error) // output and write to local file
```
