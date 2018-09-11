//
//  ViewController.swift
//  Passmenu
//
//  Created by James McDonald on 03/09/2018.
//  Copyright © 2018 James McDonald. All rights reserved.
//

import Cocoa
import Carbon.HIToolbox

let ud = UserDefaults.standard
let clearInterval = 45

// Not really content with this arrangement, but it works for now
func configurePass() -> PassFacade {
    return PassFacade(withStorePath: ud.string(forKey: Constants.prefNameStorePath)!, withPassBinary: ud.string(forKey: Constants.prefNamePassBinary)!, withPath: ud.string(forKey: Constants.prefNamePath)!)
}

class ViewController: NSViewController {
    var timer:Timer? = nil
    var results: [String] = []

    @IBOutlet weak var passwordField: NSTextField!
    @IBOutlet weak var resultTable: NSTableView!
   
    override func viewDidLoad() {
        super.viewDidLoad()
        self.resultTable.delegate = self
        self.resultTable.dataSource = self
        
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { (event) in
            guard let locWindow = self.view.window,
                NSApplication.shared.keyWindow === locWindow else { return event }
            switch Int(event.keyCode) {
            case kVK_Escape:
                (NSApp.delegate! as! AppDelegate).hideSearch(nil)
                return nil
            case kVK_DownArrow:
                self.resultTable.selectRowIndexes([self.resultTable.selectedRow+1], byExtendingSelection: false)
                self.resultTable.scrollRowToVisible(self.resultTable.selectedRow)
                return nil
            case kVK_UpArrow:
                self.resultTable.selectRowIndexes([self.resultTable.selectedRow-1], byExtendingSelection: false)
                self.resultTable.scrollRowToVisible(self.resultTable.selectedRow)
                return nil
            case kVK_Return:
                self.doubleClick(self.resultTable)
                return nil
            default:
                return event
            }
        }
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        self.view.window?.titleVisibility = .hidden
        self.view.window?.titlebarAppearsTransparent = true

        self.view.window?.styleMask.insert(.fullSizeContentView)

        self.view.window?.styleMask.remove(.closable)
        self.view.window?.styleMask.remove(.fullScreen)
        self.view.window?.styleMask.remove(.miniaturizable)
        self.view.window?.styleMask.remove(.resizable)
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        passwordField.selectText(self)
        passwordField.becomeFirstResponder()
        
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    override func controlTextDidChange(_ obj: Notification) {
        let pass = configurePass()
        let tf = obj.object as! NSTextField
        results = pass.search(tf.stringValue)
        resultTable.reloadData()
        if results.count > 0 {
            resultTable.selectRowIndexes([0], byExtendingSelection: false)
        }
    }
    
    func notify(title: String, message: String) {
        let notification = NSUserNotification();
        notification.title = title
        notification.informativeText = message
        NSUserNotificationCenter.default.deliver(notification)
    }
    
    func passNotify(_ pass: String) {
        notify(title: "Password Copied",
               message: "Password entry \"\(pass)\" copied to clipboard. It will be cleared in \(clearInterval) seconds.")
    }

    @IBAction func doubleClick(_ sender: NSTableView) {
        if sender.selectedRow < 0 {
            return
        }
        // Hide the window before starting or pinentry feels clumsy
        let delegate = NSApp.delegate! as! AppDelegate
        delegate.hideSearch(nil)
        
        let entry = results[sender.selectedRow]
        do {
            let pass = configurePass()
            let pw = try pass.getPass(entry)
        
            // Cancel pending timer
            if timer != nil {
                timer!.invalidate()
            }
            let pasteboard = NSPasteboard.general
            pasteboard.clearContents()
            pasteboard.setString(pw, forType: .string)
            timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(clearInterval), repeats: false)  { (timer) in
                pasteboard.clearContents()
            }
            passNotify(results[sender.selectedRow])
        } catch GetPassError.ExecFailed(let code, let error) {
            notify(title: "ERROR: Failed to retrieve password",
                   message: "Error response: \"\(error)\", Error code: \(code)")
        } catch GetPassError.NoBinary(let path) {
            notify(title: "ERROR: Can't find pass",
                   message: "Can't find an executable at configured path \"\(path)\"")
        } catch GetPassError.ParseFailed {
            notify(title: "ERROR: Couldn't parse response from pass",
                   message: "I ran pass OK, but what it sent me didn't look like UTF-8")
        } catch {
            notify(title: "Unexpected Error",
                   message: "Something crazy and unanticipated happened. Well done!")
        }
    }
}

extension ViewController : NSTableViewDataSource, NSTableViewDelegate {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return results.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let result = tableView.makeView(withIdentifier: (tableColumn?.identifier)!, owner: self) as! NSTableCellView
        result.textField?.stringValue = results[row]
        return result
    }
    
}
