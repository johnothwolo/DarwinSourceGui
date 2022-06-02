//
//  Project.swift
//  DarwinSourceGui
//
//  Created by John Othwolo on 5/16/21.
//  Copyright © 2021 PureDarwin. All rights reserved.
//

import Cocoa

class Project: NSObject {
    var sourceUrl: URL?
    var archiveUrl: URL?
    var projectName: String
    var projectRelease: SVNumber
    let macMinorRelease: MacMinorRelease
    
    init(_ name:String, _ macMinorRelease: MacMinorRelease) {
        self.sourceUrl = nil
        self.archiveUrl = nil
        self.projectName = name
        self.projectRelease = SVNumber(-1, -1, -1)
        self.macMinorRelease = macMinorRelease
        super.init()
    }
}

