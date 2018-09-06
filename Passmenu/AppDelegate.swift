//
//  AppDelegate.swift
//  Passmenu
//
//  Created by James McDonald on 03/09/2018.
//  Copyright © 2018 James McDonald. All rights reserved.
//

import Cocoa
import HotKey

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    
    var searchController: NSWindowController
    
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    let hotkey = HotKey(key: .p, modifiers: [.command, .option])
    
    override init() {
        // Load the popup window
        let storyboard = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil)
        let identifier = NSStoryboard.SceneIdentifier(rawValue: "WindowController")
        guard let viewcontroller = storyboard.instantiateController(withIdentifier: identifier) as? NSWindowController else {
            fatalError("Can't seem to find WindowController in Storyboard")
        }
        self.searchController = viewcontroller
        super.init()
    }

    @objc func toggleSearch(_ sender: Any?) {
        if (searchController.window?.isVisible)! {
            hideSearch(sender)
        } else {
            showSearch(sender)
        }
    }
    
    func showSearch(_ sender: Any?) {
        NSApp.activate(ignoringOtherApps: true)
        searchController.window?.center()
        searchController.window?.makeKeyAndOrderFront(nil)
    }
    
    func hideSearch(_ sender: Any?) {
        NSApp.hide(sender)
    }

    func constructMenu() {
        let menu = NSMenu()
        
        let lookupitem = NSMenuItem(title: "Look up pass", action: #selector(AppDelegate.toggleSearch(_:)), keyEquivalent: "")
        menu.addItem(lookupitem)
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit Passmenu", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        
        statusItem.menu = menu
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        if let button = statusItem.button {
            button.image = NSImage(named: NSImage.Name("StatusBarButtonImage"))
        }
        
        constructMenu()

        hotkey.keyUpHandler = {
            self.toggleSearch(nil)
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

