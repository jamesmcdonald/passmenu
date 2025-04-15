//
//  AppDelegate.swift
//  Passmenu
//
//  Created by James McDonald on 03/09/2018.
//  Copyright © 2018 James McDonald. All rights reserved.
//

import Cocoa
import HotKey
import UserNotifications

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    var searchController: NSWindowController
    var prefsController: NSWindowController
    
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    let hotkey = HotKey(key: .p, modifiers: [.command, .option])
    
    override init() {
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        let identifier = NSStoryboard.SceneIdentifier("WindowController")
        guard let searchController = storyboard.instantiateController(withIdentifier: identifier) as? NSWindowController else {
            fatalError("Can't seem to find WindowController in Storyboard")
        }
        self.searchController = searchController
        
        let prefsid = NSStoryboard.SceneIdentifier("PrefsWindowController")
        guard let prefsController = storyboard.instantiateController(withIdentifier: prefsid) as? NSWindowController else {
            fatalError("Can't seem to find PrefsWindowController in Storyboard")
        }
        self.prefsController = prefsController
        
        super.init()
    }

    @MainActor @objc func showPrefs(_ sender: Any?) {
        NSApp.activate(ignoringOtherApps: true)
        prefsController.window?.makeKeyAndOrderFront(sender)
    }
    
    @MainActor @objc func toggleSearch(_ sender: Any?) {
        if (searchController.window?.isVisible)! {
            hideSearch(sender)
        } else {
            showSearch(sender)
        }
    }
    
    @MainActor func showSearch(_ sender: Any?) {
        NSApp.activate(ignoringOtherApps: true)
        searchController.window?.center()
        searchController.window?.makeKeyAndOrderFront(nil)
    }
    
    @MainActor func hideSearch(_ sender: Any?) {
        searchController.window?.close()
    }

    func constructMenu() {
        let menu = NSMenu()
        
        let lookupitem = NSMenuItem(title: "Look up pass", action: #selector(AppDelegate.toggleSearch(_:)), keyEquivalent: "")
        menu.addItem(lookupitem)
        let prefsitem = NSMenuItem(title: "Preferences...", action: #selector(AppDelegate.showPrefs(_:)), keyEquivalent: "")
        menu.addItem(prefsitem)
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit Passmenu", action: #selector(NSApplication.terminate(_:)), keyEquivalent: ""))
        
        statusItem.menu = menu
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Set default UserDefaults
        let ud = UserDefaults.standard
        if ud.string(forKey: Constants.prefNamePassBinary) == nil {
            ud.set(Constants.defaultPassBinary, forKey: Constants.prefNamePassBinary)
        }
        if ud.string(forKey: Constants.prefNamePath) == nil {
            ud.set(Constants.defaultPath, forKey: Constants.prefNamePath)
        }
        if ud.string(forKey: Constants.prefNameStorePath) == nil {
            ud.set(Constants.defaultStorePath, forKey: Constants.prefNameStorePath)
        }

        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "key", accessibilityDescription: "passmenu")
        }
        
        constructMenu()

        hotkey.keyUpHandler = {
            self.toggleSearch(nil)
        }
        
        Task.detached {
            do {
                let granted = try await UNUserNotificationCenter.current()
                    .requestAuthorization(options: [.alert, .badge, .sound])

                await MainActor.run {
                    print("Notifications permission granted: \(granted)")
                }
            } catch {
                await MainActor.run {
                    print("Request authorization failed: \(error)")
                }
            }
        }
        
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}
