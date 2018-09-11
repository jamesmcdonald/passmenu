//
//  PrefsViewController.swift
//  Passmenu
//
//  Created by James McDonald on 09/09/2018.
//  Copyright © 2018 James McDonald. All rights reserved.
//

import Cocoa

let defaultPath = "/usr/local/bin:/usr/bin:/bin"

class PrefsViewController: NSViewController {
    var passPath = "/usr/local/bin/pass"
    var path = "/usr/local/bin:/usr/bin:/bin"

    @IBOutlet weak var passField: NSTextField!
    @IBOutlet weak var pathField: NSTextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        passField.stringValue = passPath
        pathField.stringValue = path
    }
   
    @IBAction func okClicked(_ sender: Any) {
        self.passPath = passField.stringValue
        self.path = pathField.stringValue
        view.window?.performClose(sender)
    }
    @IBAction func cancelClicked(_ sender: Any) {
        view.window?.performClose(sender)
    }
    @IBAction func passButtonClicked(_ sender: Any) {
        let openPanel = NSOpenPanel()
        openPanel.resolvesAliases = false
        openPanel.directoryURL = URL(fileURLWithPath: passField.stringValue)
        let r = openPanel.runModal()
        if r == NSApplication.ModalResponse.OK {
            passField.stringValue = (openPanel.url?.path)!
        }
    }
}
