//
//  PassFacade.swift
//  Passmenu
//
//  Created by James McDonald on 03/09/2018.
//  Copyright © 2018 James McDonald. All rights reserved.
//

import Cocoa

enum GetPassError: Error {
    case NoBinary(path: String)
    case ExecFailed(code: Int32, stderr: String)
    case ParseFailed
}

class PassFacade: NSObject {
    var storePath: String
    var passBinary: String
    var path: String

    init(withStorePath storePath: String = Constants.defaultStorePath, withPassBinary passBinary: String = Constants.defaultPassBinary, withPath path: String = Constants.defaultPath) {
        self.storePath = storePath
        self.passBinary = passBinary
        self.path = path
    }

    func search(_ s: String) -> [String] {
        let fileManager = FileManager.default
        var result: [String] = []
        
        if let enumerator = fileManager.enumerator(atPath: storePath) {
            for file in enumerator {
                let fn = file as! String
                if fn.hasSuffix(".gpg") && fn.contains(s) {
                    result.append(String(fn.dropLast(4)))
                }
            }
        } else {
            fatalError("Can't open password store at " + storePath)
        }
        return result;
    }

    func getPass(_ p:String, passOnly: Bool = true) throws -> String {
        let task = Process()
        let outpipe = Pipe()
        let errpipe = Pipe()
        
        let filemanager = FileManager.default
        
        guard filemanager.isExecutableFile(atPath: passBinary) else {
            throw GetPassError.NoBinary(path: passBinary)
        }

        task.executableURL = URL(fileURLWithPath: passBinary)
        task.arguments = [p]
        task.standardOutput = outpipe
        task.standardError = errpipe
        // Set up environment explicitly - the default PATH doesn't work with Homebrew
        task.environment = [
            "PATH":               path,
            "HOME":               NSHomeDirectory(),
            "PASSWORD_STORE_DIR": storePath,
        ]

        try task.run()
        let outdata = outpipe.fileHandleForReading.readDataToEndOfFile()
        task.waitUntilExit()

        guard task.terminationStatus == 0 else {
            let errordata = errpipe.fileHandleForReading.readDataToEndOfFile()
            if let errstring = String(data: errordata, encoding: String.Encoding.utf8)  {
                throw GetPassError.ExecFailed(code: task.terminationStatus, stderr: errstring)
            } else {
                throw GetPassError.ExecFailed(code: task.terminationStatus, stderr: "[could not parse stderr]")
            }
        }

        if let output = String(data: outdata, encoding: String.Encoding.utf8)?
            .trimmingCharacters(in: CharacterSet.newlines)
            .components(separatedBy: CharacterSet.newlines) {
            if passOnly {
                return output[0]
            }
            return output.joined(separator: "\n")
        }
        throw GetPassError.ParseFailed
    }
}
