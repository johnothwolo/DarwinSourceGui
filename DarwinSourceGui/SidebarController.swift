//
//  SidebarViewController.swift
//  DarwinSourceGui
//
//  Created by John Othwolo on 5/15/21.
//  Copyright © 2021 PureDarwin. All rights reserved.
//

import Foundation
import Cocoa

class SidebarViewController: NSViewController {
    
    @IBOutlet weak var sourceList: NSOutlineView!
    
    var sourceData: DataSource!
    var macosReleases: MacMajorReleases!
    let notifCenter: NotificationCenter = NotificationCenter.default
    
    override func viewWillLayout() {
        preferredContentSize.width = self.view.bounds.size.width
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do view setup here
        sourceData = DataSource.sharedInstance
        macosReleases = sourceData.getMacOSVersions()!
        sourceList.dataSource = self
        sourceList.delegate = self
                
        self.setWindowContent(macosReleases[0].minorReleases[0])
    }
}

extension SidebarViewController : NSOutlineViewDelegate {
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        var view: NSTableCellView?
        
        if let major = item as? MacMajorRelease {
            view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "MajorRelease"), owner: self) as? NSTableCellView
            if let textField = view?.textField {
                textField.stringValue = MacMajorRelease.getFullReleaseName(major.releaseNumber) // major.releaseName
                textField.sizeToFit()
            }

        } else if let minor = item as? MacMinorRelease {
            view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "MinorRelease"), owner: self) as? NSTableCellView

            if let textField = view?.textField {
                //5
                textField.stringValue = minor.releaseName
                textField.sizeToFit()
            }
        } else {
            print("MainSidebarViewController: Unknown type item=\(item)")
        }
        
        return view
    }
    
    // TODO: send notification to the ContentView
    func outlineViewSelectionDidChange(_ notification: Notification) {
        guard let outlineView = notification.object as? NSOutlineView else {
            return
        }
        
        let selectedIndex = outlineView.selectedRow
        if let minor = outlineView.item(atRow: selectedIndex) as? MacMinorRelease {
            self.setWindowContent(minor)
        } else {
            return
        }
    }
    
    func setWindowContent(_ minor: MacMinorRelease){
        notifCenter.post(name: NSNotification.Name(rawValue: "setWindowContent"), object: minor)
    }
}

extension SidebarViewController : NSOutlineViewDataSource {
    
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if let release = item as? MacMajorRelease {
            return release.minorReleases.count
        } else {
            return macosReleases.count
        }
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if let release = item as? MacMajorRelease {
            if index > release.minorReleases.count {
                return 0
            }
            return release.minorReleases[index] as Any
        }
        return macosReleases[index] as Any
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        if let list = item as? MacMajorRelease {
            return list.minorReleases.count > 0
        }
        return false
    }
}

extension SidebarViewController: NSSplitViewDelegate {
    func splitView(_ splitView: NSSplitView, effectiveRect proposedEffectiveRect: NSRect, forDrawnRect drawnRect: NSRect, ofDividerAt dividerIndex: Int) -> NSRect {
        return .zero
    }
    
}
