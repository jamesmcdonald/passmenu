//
//  ViewController.swift
//  Passmenu
//
//  Created by James McDonald on 03/09/2018.
//  Copyright © 2018 James McDonald. All rights reserved.
//

import Cocoa
import Carbon.HIToolbox

let clearInterval = 45

class ViewController: NSViewController {
    var timer:Timer? = nil

    @IBOutlet weak var passwordField: NSTextField!
    @IBOutlet weak var resultTable: NSTableView!
    @IBAction func doubleClick(_ sender: NSTableView) {
        if sender.selectedRow < 0 {
            return
        }
        // Hide the window before starting or pinentry feels clumsy
        let delegate = NSApp.delegate! as! AppDelegate
        delegate.hideSearch(nil)
        
        let entry = results[sender.selectedRow]
        let pw = pass.getPass(entry)

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
    }
    
    let pass = PassFacade()
    var results: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.resultTable.delegate = self
        self.resultTable.dataSource = self
        
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { (event) in
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
        let tf = obj.object as! NSTextField
        results = pass.search(tf.stringValue)
        resultTable.reloadData()
        if results.count > 0 {
            resultTable.selectRowIndexes([0], byExtendingSelection: false)
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
