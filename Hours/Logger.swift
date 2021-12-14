//
//  Logger.swift
//  Hours
//
//  Created by Ariel Steiner on 14/12/2021.
//

import Foundation

let logger : FileHandle = {
    do {
        let url = try FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("Hours.txt")
        if !FileManager.default.fileExists(atPath: url.path) {
            FileManager.default.createFile(atPath: url.path, contents: nil, attributes: [:])
        }
        let log = try FileHandle(forWritingTo: url)
        return log
    } catch {
        print("Warning: couldn't create a log file. \(error). Printing to console...")
        return FileHandle.standardOutput
    }
}()

extension FileHandle {
    func log(_ message: String) {
        print(message)
        do {
            try self.seekToEnd()
            self.write(Data("\(Date()) \(message)\n".utf8))
        } catch {
            print("Can't write to file. \(error)")
        }
    }
}
