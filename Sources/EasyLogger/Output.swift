//
//  File.swift
//  
//
//  Created by i on 2023/2/7.
//

import Foundation
import Logging

public protocol Output {
    var label: String { get }
    var level: Logging.Logger.Level { get }
    
    func output(label: String, level: Logging.Logger.Level, timestamp: String, message: String)
}
