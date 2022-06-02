//
//  AppDelegate.swift
//  DarwinSourceGui
//
//  Created by John Othwolo on 5/14/21.
//  Copyright © 2021 PureDarwin. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        let userdefs = UserDefaults.standard
        
        if !userdefs.bool(forKey: "not_first_launch") {
            userdefs.insertValue(true, inPropertyWithKey: "not_first_launch")
            userdefs.insertValue(true, inPropertyWithKey: "show_ppc")
        } else {
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

}

