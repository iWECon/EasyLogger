import Foundation
import Logging

extension Logger {
    
    func report(
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

struct GlobalQueue {
    static var shared = GlobalQueue()
    
    let queue: OperationQueue = .init()
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
    
    public let generationTime: GenerationTime.Type
    public let transform: any Transform
    public let outputs: [Output]
    
    let operationQueue: OperationQueue
    
    public init(
        label: String,
        logLevel: Logging.Logger.Level,
        operationQueue: OperationQueue? = nil,
        generationTime: GenerationTime.Type = DefaultGenerationTime.self,
        transform: (_ label: String) -> Transform = { label in
            DefaultTransform(label: label)
        },
        outputs: (_ label: String, _ level: Logging.Logger.Level) -> [Output] = { (label, level) -> [Output] in
            [DefaultOutput(label: label, level: level)]
        }
    ) {
        self.label = label
        self.logLevel = logLevel
        self.operationQueue = operationQueue ?? GlobalQueue.shared.queue
        
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
                metadata: metadata,
                source: source, file: file, function: function, line: line
            )
            let timestamp = self.generationTime.timestamp()
            
            self.outputs.forEach { $0.output(label: self.label, level: level, timestamp: timestamp, message: output) }
        }
    }
    
}
