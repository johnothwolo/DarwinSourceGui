//
//  SourceData.swift
//  DarwinSourceGui
//
//  Created by John Othwolo on 5/15/21.
//  Copyright © 2021 PureDarwin. All rights reserved.
//

import Cocoa
import SwiftSoup

enum kVDProjectsEnum {
    case dtrace
    case AvailabilityVersions
    case libdispatch
    case libplatform
    case Libsystem
    case xnu
}

typealias MacMinorReleases = Array<MacMinorRelease>
typealias MacMajorReleases = Array<MacMajorRelease>
typealias MacOSDictionary = Dictionary<String, Array<URL?>>
typealias ProjectArray = Array<Project>

// make the apple website also a setting
let mainPage = "https://opensource.apple.com/"
let releasePage = "/release/"
let sourcePage = "/source/"

// Kernel-SVNumber Dependent Projects
let kVDProjects:Array<String> = [
    "dtrace",
    "AvailabilityVersions",
    "libdispatch",
    "libplatform",
    "Libsystem",
    "xnu"
];

class DataSource : NSObject {
    
    static let sharedInstance = DataSource()
    
    func getMacOSVersions() -> MacMajorReleases? {
        let htmlString:String
        let htmlSoup:Document
        var majors: Array<MacMajorRelease> = []
        let userPref = UserDefaults.standard
        
        do {
            let url = URL(string: "https://opensource.apple.com/")!
            htmlString = try String(contentsOf: url, encoding: .utf8)
        } catch let error {
            print("Cannot connect to Apple opensource website. Error: \(error.localizedDescription)")
            return nil
        }

        do {
            htmlSoup = try SwiftSoup.parse(htmlString)
            
            // actual parsing...
            let macOSReleaselist = try htmlSoup.getElementsByClass("product release-list").first()
            let listname = try macOSReleaselist?.getElementsByClass("product-name")
            var components = URLComponents()
            let majorSubLists: Array<Element>
            
            components.scheme = "https"
            components.host = "opensource.apple.com"
            
            if try listname?.text() != "macOS" {
                print("Error: Header '\(String(describing: try listname?.text()))' does not match expected value (macOS)")
                return nil
            }
            
            majorSubLists = try macOSReleaselist!.getElementsByClass("release-sublist").array()
            // traverse through macos MAJOR versions
            for majorSubList:Element in majorSubLists {
                let majorString:String
                let minorElements: Array<Element>
                let major:MacMajorRelease
                var minors:Array<MacMinorRelease> = []
                
                let _temp1 = majorSubList.id()
                majorString = _temp1.split(separator: "-").map(String.init).last!
                major = MacMajorRelease(releaseName: majorString, releaseNumber: SVNumber(majorString))
                minorElements = try majorSubList.getElementsByTag("a").array()
                
    //            print(minorElements.count)
                minors.reserveCapacity(minorElements.count)

                // traverse through minor releases
                for subRelease:Element in minorElements {
                    var minorReleaseString:String
                    let minorLink:String
                    let minor: MacMinorRelease
                    
                    minorReleaseString = try subRelease.text()
                    minor = MacMinorRelease(majorRelease: major)
                    minorLink = try subRelease.attr("href")
                    
                    // TODO: make this a setting in future preferences
                    if !userPref.bool(forKey: "show_ppc") {
                        if minorReleaseString.contains("ppc") { continue } ;
                    } else {
                        // TODO: show (ppc) or (x86) if this is enabled
                        
                    }
                    
                    // get rid of any trailing components
                    let minorStringArray = minorReleaseString.split(separator: ".")
                    if minorStringArray.count > 3 {
                        minorReleaseString = "\(minorStringArray[0]).\(minorStringArray[1]).\(minorStringArray[2])"
                    }
                    
                    if !minorLink.isEmpty {
                        components.path = minorLink
                        minor.url = components.url!
                        print(minor.url.absoluteString)
                    }
                    minor.releaseName = minorReleaseString
                    minor.releaseNumber = SVNumber(minorReleaseString)
                    minors.append(minor)
                }
                // set the minor releases for this major release
                major.minorReleases = minors
                majors.append(major)
            }
            // return the array of major releases
            return majors
            
        } catch let error {
            print("Error: '\(error.localizedDescription)'. Could not parse HTML")
            return nil
        }
    }
    
    func getProjects(_ forMacOSMinorRelease:MacMinorRelease) -> ProjectArray? {
        let htmlString:String
        let htmlSoup:Document
        
        if forMacOSMinorRelease.url.host != "opensource.apple.com" {
            print("[warning]: This is not an apple link")
            return nil
        }
        
        do {
            htmlString = try String(contentsOf: forMacOSMinorRelease.url, encoding: .utf8)
        } catch let error{
            print("Cannot connect to Apple opensource website. Error: \(error.localizedDescription)")
            return nil
        }

        do {
            htmlSoup = try SwiftSoup.parse(htmlString)
            
            // actual parsing...
            let projectList = try htmlSoup.getElementsByClass("project-row")
            var components = URLComponents()
            var projectArrary:ProjectArray = []
            
            components.scheme = forMacOSMinorRelease.url.scheme
            components.host = forMacOSMinorRelease.url.host
            
            // traverse through macos projects
            for currentProjectElement:Element in projectList {
                let rawProjectString:String = try currentProjectElement.text().trimmingCharacters(in: .init(charactersIn: "•")).trimmingCharacters(in: .whitespacesAndNewlines) // with version
                let projectnametag = currentProjectElement.child(1 /* the second one */)
                let projectdownloadtag = currentProjectElement.child(2 /* the third one */)
                let projectString = String((rawProjectString.split(separator: "-"))[0])
                let projectVersionString = String((rawProjectString.split(separator: "-"))[1])
                let project = Project(projectString, forMacOSMinorRelease)

                
                if let sourceUrlPath = try? projectnametag.child(0).attr("href") {
                    components.path = sourceUrlPath
                    project.sourceUrl = components.url!
                } else {
                    print("Bad source url")
                    project.sourceUrl = nil
                }
                
                // not all projects have downloads
                if projectdownloadtag.children().count > 0 {
                    if let tarballUrlPath = try? projectdownloadtag.child(0).attr("href"){
                        components.path = tarballUrlPath
                        project.archiveUrl = components.url!
                    } else {
                        print("Bad archive url")
                        project.archiveUrl = nil
                    }
                } else {
                    project.archiveUrl = nil
                }
                
                
                project.projectRelease = SVNumber(projectVersionString)
    //            print(String(describing: projectString))
    //            print(String(describing: srcUrl.absoluteString))
    //            print(String(describing: tarUrl.absoluteString))
                projectArrary.append(project)
            }
            return projectArrary
            
        } catch let error {
            print("Error: '\(error.localizedDescription)'. Could not parse HTML")
            return nil
        }
        
    }
    
}
