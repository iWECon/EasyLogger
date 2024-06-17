import Foundation
import Logging

struct LoggerQueue: Sendable {
    
    static var shared = LoggerQueue()
    
    let queue = SendableOperationQueue()
    private init() {
        queue.maxConcurrentOperationCount = 1
        queue.name = "in.iiiam.logger.queue"
        queue.underlyingQueue = .global(qos: .utility)
    }
}

public struct EasyLogger: LogHandler {
    
    public var metadata: Logging.Logger.Metadata = .init()
    public var logLevel: Logging.Logger.Level = .info
    
    @usableFromInline
    let label: String
    
    public let generationTime: any GenerationTime
    public let transform: any Transform
    public let outputs: [Output]
    
    let operationQueue: SendableOperationQueue
    
    public init(
        label: String,
        logLevel: Logging.Logger.Level,
        queue: SendableOperationQueue? = nil,
        generationTime: any GenerationTime = DefaultGenerationTime(),
        transform: (_ label: String) -> Transform = { label in
            DefaultTransform(label: label)
        },
        outputs: (_ label: String, _ level: Logging.Logger.Level) -> [Output] = { (label, level) -> [Output] in
            [DefaultOutput(label: label, level: level)]
        }
    ) {
        self.label = label
        self.logLevel = logLevel
        self.operationQueue = queue ?? LoggerQueue.shared.queue
        
        self.generationTime = generationTime
        self.transform = transform(label)
        self.outputs = outputs(label, logLevel)
    }
    
    public subscript(metadataKey key: String) -> Logging.Logger.Metadata.Value? {
        get {
            metadata[key]
        }
        set(newValue) {
            metadata[key] = newValue
        }
    }
    
    public func log(
        level: Logger.Level,
        message: Logger.Message,
        metadata: Logger.Metadata?,
        source: String, file: String, function: String, line: UInt
    ) {
        operationQueue.addOperation {
            let output = self.transform.transform(
                level: level,
                message: message,
                baseMetadata: self.metadata,
                metadata: metadata,
                source: source, file: file, function: function, line: line
            )
            let timestamp = self.generationTime.timestamp()
            
            self.outputs.forEach { $0.output(label: self.label, level: level, timestamp: timestamp, message: output) }
        }
    }
    
}
