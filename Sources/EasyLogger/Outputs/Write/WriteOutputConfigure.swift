//
//  File.swift
//  
//
//  Created by bro on 2023/2/8.
//

import Foundation
#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
import Darwin
#elseif os(Windows)
import CRT
#elseif canImport(Glibc)
import Glibc
#elseif canImport(WASILibc)
import WASILibc
#else
#error("Unsupported runtime")
#endif

/// This configuration should be changed before using `Logger`, or use `lazy var` to delay `Logger.init'.
public struct WriteOutputConfigure {
    public static var `default` = WriteOutputConfigure()
    
    /// The name of the currently stored log (automatically generated each time the app is cold-started).
    public var currentLogName: String
    
    /// The directory where logs are stored.
    /// Defaults to `File Manager.default.urls(for: .caches Directory, in: .user Domain Mask).first`.
    public var localCacheDirectory: URL {
        didSet {
            removeOldCacheDir(oldDir: oldValue)
            createCacheAndLogFile()
        }
    }
    
    /// Readonly. The specific path where logs are currently stored.
    /// `localCacheDirectory` is concatenated with `currentLogName`.
    public var currentLogFilePath: URL {
        if #available(iOS 16.0, *) {
            return localCacheDirectory.appending(path: currentLogName)
        }
        return localCacheDirectory.appendingPathComponent(currentLogName)
    }
    
    /// When writing to the log, a split symbol will be added to facilitate split use in some scenarios.
    /// Defaults to `[space][space][space]\n`.
    public var delimiter: String = "   \n"
    
    private init() {
        func nameTimestamp() -> String {
            var buffer = [Int8](repeating: 0, count: 255)
            var timestamp = time(nil)
            let localTime = localtime(&timestamp)
            strftime(&buffer, buffer.count, "%Y%m%d_%H%M%S", localTime)
            return buffer.withUnsafeBufferPointer {
                $0.withMemoryRebound(to: CChar.self) {
                    String(cString: $0.baseAddress!)
                }
            }
        }
        self.currentLogName = "logger-\(nameTimestamp()).log"
        
        let localCacheDirectory: URL
        if #available(iOS 16.0, *) {
            localCacheDirectory = .cachesDirectory
        } else {
            localCacheDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        }
        // - subpath
        let subpath = "\(Bundle.main.bundleIdentifier ?? "in.iiiam.logger")/logger-caches"
        if #available(iOS 16.0, *) {
            self.localCacheDirectory = localCacheDirectory.appending(path: subpath)
        } else {
            self.localCacheDirectory = localCacheDirectory.appendingPathComponent(subpath)
        }
        
        self.createCacheAndLogFile()
    }
    
    private func removeOldCacheDir(oldDir: URL) {
        do {
            try FileManager.default.removeItem(at: oldDir)
        } catch {
            print("[WriteOutputConfigure] [localCacheDirectory.didSet] [removeOldCacheDir] > failed: \(error.localizedDescription)")
        }
    }
    
    private func createCacheAndLogFile() {
        do {
            try FileManager.default.createDirectory(at: localCacheDirectory, withIntermediateDirectories: true)
            defer {
                print("[WriteOutputConfigure] [localCacheDirectory.didSet] > current log save path: \(currentLogFilePath.outputPath())")
            }
            guard !FileManager.default.fileExists(atPath: currentLogFilePath.outputPath()) else { return }
            FileManager.default.createFile(atPath: currentLogFilePath.outputPath(), contents: nil)
        } catch {
            print("[WriteOutputConfigure] [createCacheAndLogFile] > failed: \(error.localizedDescription)")
        }
    }
}
