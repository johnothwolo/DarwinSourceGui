//
//  SVNumber.swift
//  DarwinSourceGui
//
//  Created by John Othwolo on 5/15/21.
//  Copyright © 2021 PureDarwin. All rights reserved.
//

import Foundation

// Semantic-Version-Number class
// it coontains contigencies for irregular version strings
// it'll just store the extra irregularities and print the irregular string but keep the
// expected conformant number

class SVNumber: NSObject{
    
    let major:Int
    let minor:Int
    let patch:Int
    
    // for irregular semantic version numbers
    let irregular: Bool
    private let irregularVersionArray: Array<Any>
    private let irregularVersionString: String
    
    var isValid:Bool {
        get {
            return self.major >= 0 && self.minor >= 0 && self.patch >= 0
        }
    }

    init(_ major: Int, _ minor: Int, _ patch: Int) {
        self.major = major
        self.minor = minor
        self.patch = patch
        self.irregular = false
        self.irregularVersionString = "(nil)"
        self.irregularVersionArray = []
    }
    
    init(_ versionString: String) {
        let maybes = versionString.split(separator: ".", omittingEmptySubsequences: false).map{
            Int($0)
        }
        
        guard !maybes.contains(nil), 1...3 ~= maybes.count else {
            self.major = -1
            self.minor = -1
            self.patch = -1
            self.irregularVersionArray = []
            self.irregular = true
            self.irregularVersionString = versionString
            super.init()
            return
        }
        
        var versionArray = maybes.map{ $0! }
        
        while versionArray.count < 3 {
            versionArray.append(0)
        }
        
        self.irregularVersionArray = versionArray
        
        self.major = versionArray[0]
        self.minor = versionArray[1]
        self.patch = versionArray[2]
        self.irregular = maybes.count > 3
        self.irregularVersionString = versionString
        super.init()
    }
    
    func intVersion() -> Int {
        return (self.major * 100) + self.minor + self.patch
    }
    
    func majorReleaseString() -> String {
        return "\(self.major)"
    }
    
    func minorReleaseString() -> String {
        return "\(self.major).\(self.minor)"
    }
    
    // returns the irregular string if irregular is true
    func originalVersionString() -> String {
        if self.irregular{
            return self.irregularVersionString
        } else {
            return "\(self.major).\(self.minor).\(self.patch)"
        }
    }
    
    func conformantVersionString() -> String {
        return "\(self.major).\(self.minor).\(self.patch)"
    }
    
    static func < (left: SVNumber, right: SVNumber) -> Bool {
        return left.major < right.major ? left.minor < right.minor ? true : false : false
    }
    
    static func > (left: SVNumber, right: SVNumber) -> Bool {
        return left.major > right.major ? left.minor > right.minor ? true : false : false
    }
    
    static func == (left: SVNumber, right: SVNumber) -> Bool {
        return left.major == right.major ? left.minor == right.minor ? true : false : false
    }
    
    // create a static function to check the validity of any semantic version string
    static func isValidString(_ versionString: String) -> Bool {
        return versionString.split(separator: ".").count > 3
    }
}
