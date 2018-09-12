//
//  Constants.swift
//  Passmenu
//
//  Created by James McDonald on 11/09/2018.
//  Copyright © 2018 James McDonald. All rights reserved.
//

import Cocoa

// Static strings
struct Constants {
    static let defaultPassBinary = "/usr/local/bin/pass"
    static let defaultStorePath = NSHomeDirectory() + "/.password-store"
    static let defaultPath = "/usr/local/bin:/usr/bin:/bin"
    
    static let prefNamePassBinary = "passBinary"
    static let prefNameStorePath = "storePath"
    static let prefNamePath = "path"
}
