//
//  PassFacade.swift
//  Passmenu
//
//  Created by James McDonald on 03/09/2018.
//  Copyright © 2018 James McDonald. All rights reserved.
//

import Cocoa

let defaultPassBinary = "/usr/local/bin/pass"
let defaultStorePath = NSHomeDirectory() + "/.password-store"

class PassFacade: NSObject {
    var storePath:String
    var passBinary:String

    init(withStorePath path: String = defaultStorePath, withPassBinary binary: String = defaultPassBinary) {
        storePath = path
        passBinary = binary
    }
    
    func search(_ s:String) -> [String] {
        let fileManager = FileManager.default
        var result:[String] = []
        
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
    
    func getPass(_ p:String, passOnly: Bool = true) -> String {
        var output: [String] = []
        
        let task = Process()
        task.launchPath = passBinary
        task.arguments = [p]
        // Set up environment explicitly - the default PATH doesn't work
        task.environment = ["PATH":"/usr/local/bin:/usr/bin:/bin","HOME":NSHomeDirectory()]
        let outpipe = Pipe()
        task.standardOutput = outpipe
        task.launch()
        let outdata = outpipe.fileHandleForReading.readDataToEndOfFile()
        if var string = String(data: outdata, encoding: String.Encoding.utf8) {
            string = string.trimmingCharacters(in: CharacterSet.newlines)
            output = string.components(separatedBy: CharacterSet.newlines)
        }
        
        if passOnly {
            return output[0]
        }
        return output.joined(separator: "\n")
    }
}
