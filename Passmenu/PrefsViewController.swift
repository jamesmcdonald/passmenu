//
//  PrefsViewController.swift
//  Passmenu
//
//  Created by James McDonald on 09/09/2018.
//  Copyright © 2018 James McDonald. All rights reserved.
//

import Cocoa

// This view uses UserDefaults directly as its "model"
class PrefsViewController: NSViewController {
    @IBOutlet weak var passField: NSTextField!
    @IBOutlet weak var pathField: NSTextField!
    @IBOutlet weak var storePathField: NSTextField!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        let ud = UserDefaults.standard
        passField.stringValue = ud.string(forKey: Constants.prefNamePassBinary)!
        pathField.stringValue = ud.string(forKey: Constants.prefNamePath)!
        storePathField.stringValue = ud.string(forKey: Constants.prefNameStorePath)!
    }
    
    @IBAction func okClicked(_ sender: Any) {
        let ud = UserDefaults.standard
        ud.set(passField.stringValue, forKey: Constants.prefNamePassBinary)
        ud.set(pathField.stringValue, forKey: Constants.prefNamePath)
        ud.set(storePathField.stringValue, forKey: Constants.prefNameStorePath)
        view.window?.performClose(sender)
    }

    @IBAction func cancelClicked(_ sender: Any) {
        view.window?.performClose(sender)
    }

    @IBAction func passResetClicked(_ sender: Any) {
        passField.stringValue = Constants.defaultPassBinary
    }

    @IBAction func pathResetClicked(_ sender: Any) {
        pathField.stringValue = Constants.defaultPath
    }
    
    @IBAction func storePathResetClicked(_ sender: Any) {
        storePathField.stringValue = Constants.defaultStorePath
    }

    @IBAction func storePathOpenClicked(_ sender: Any) {
        let openPanel = NSOpenPanel()
        openPanel.canChooseFiles = false
        openPanel.canChooseDirectories = true
        openPanel.showsHiddenFiles = true
        openPanel.directoryURL = URL(fileURLWithPath: storePathField.stringValue)
        let r = openPanel.runModal()
        if r == NSApplication.ModalResponse.OK {
            storePathField.stringValue = (openPanel.url?.path)!
        }
    }

    @IBAction func passOpenClicked(_ sender: Any) {
        let openPanel = NSOpenPanel()
        openPanel.showsHiddenFiles = true
        openPanel.directoryURL = URL(fileURLWithPath: passField.stringValue)
        let r = openPanel.runModal()
        if r == NSApplication.ModalResponse.OK {
            passField.stringValue = (openPanel.url?.path)!
        }
    }
}
