//
//  MacRelease.swift
//  DarwinSourceGui
//
//  Created by John Othwolo on 5/15/21.
//  Copyright © 2021 PureDarwin. All rights reserved.
//

import Foundation

protocol MacRelease: NSObject {
    var isMajorRelease: Bool { get }
    var releaseNumber: SVNumber { get }
}

class MacMajorRelease: NSObject, MacRelease {
    let isMajorRelease: Bool
    let releaseName: String
    let releaseNumber: SVNumber
    var minorReleases: Array<MacMinorRelease>
    
    init(releaseName: String) {
        self.isMajorRelease = true
        self.minorReleases = []
        self.releaseNumber = SVNumber(-1, -1, -1)
        self.releaseName = releaseName
        super.init()
    }
    
    init(releaseNumber: SVNumber) {
        self.isMajorRelease = true
        self.minorReleases = []
        self.releaseNumber = releaseNumber
        self.releaseName = "(nil)"
        super.init()
    }
    
    init(releaseName: String, releaseNumber: SVNumber) {
        self.isMajorRelease = true
        self.minorReleases = []
        self.releaseNumber = releaseNumber
        self.releaseName = releaseName
        super.init()
    }
    
    // OSX or macOS
    static func getFullReleaseName(_ version:SVNumber, _ withPatch:Bool = false) -> String {
        if version.major == 10 && version.minor <= 11 { // 10.11
            return withPatch ? "OSX \(version.major).\(version.minor).\(version.patch)"
                             : "OSX \(version.major).\(version.minor)"
        } else {
            return withPatch ? "macOS \(version.major).\(version.minor).\(version.patch)"
                             : "macOS \(version.major).\(version.minor)"
        }
    }
}

class MacMinorRelease: NSObject, MacRelease {
    var url: URL
    let isMajorRelease: Bool
    var releaseName: String
    var releaseNumber: SVNumber
    let majorRelease: MacMajorRelease
    var projects: ProjectArray

    init(majorRelease: MacMajorRelease) {
        self.url = URL(string: "http://google.com")!
        self.isMajorRelease = false
        self.majorRelease = majorRelease
        self.releaseName = "(nil)"
        self.releaseNumber = SVNumber(-1, -1, -1)
        self.projects = []
        super.init()
    }
}
