//
//  ContentViewController.swift
//  DarwinSourceGui
//
//  Created by John Othwolo on 5/14/21.
//  Copyright © 2021 PureDarwin. All rights reserved.
//

import Cocoa

class ContentViewController: NSViewController {
   
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet var splitView: NSSplitView!
    @IBOutlet weak var downloadButton: NSButton!
    @IBOutlet weak var numberofitems: NSTextField!
    
    let notifCenter = NotificationCenter.default
    var cache: Dictionary<String, ProjectArray> = [:] // cached MacMinorReleases
    var minorRelease: MacMinorRelease! = nil
    var tableData = ProjectArray() //= Array<ProjectArray>()
    var destPath = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
//        splitView.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
        
        downloadButton.contentTintColor = .white
        
        notifCenter.addObserver(self, selector: #selector(changeContent), name: NSNotification.Name(rawValue: "setWindowContent"), object: nil)
        
    }
    
    @objc func changeContent(notif: NSNotification){
        if let _minor:MacMinorRelease = (notif.object as? MacMinorRelease) {
            // get our data from the cache or get new data
            self.minorRelease = _minor //  set our macos release
            if let data = self.cache[self.minorRelease.releaseName] {
                self.tableData = data
            } else {
                autoreleasepool {
                    self.tableData = DataSource.sharedInstance.getProjects(self.minorRelease)! // get project data
                }
                self.cache[minorRelease.releaseName] = self.tableData
            }
            self.tableView.reloadData()
            self.numberofitems.stringValue = "\(tableData.count) items"
        } else {
            // debug this case scenario
            return
        }
        
    }

    @IBAction func downloadClicked(_ sender: Any) {
        if minorRelease != nil && checkedCells.count > 0{
            let dialog = NSOpenPanel()
            var destination: URL
            let dm = DownloadManager()
            let projects = Array(checkedCells.values)
            
            
            dialog.canChooseFiles = false
            dialog.canChooseDirectories = true
            dialog.runModal()
            
            if dialog.url != nil {
                destination = dialog.url!
            } else {
//                destination = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first!
                return
                
            }
            var i = 0
            for project in projects {
                let destStr = destination.appendingPathComponent(project.archiveUrl!.lastPathComponent).path
                if FileManager.default.fileExists(atPath: destStr){
                    continue
                }
                dm.queueDownload(project, destination)
                print(destStr)
                i+=1
            }
            print(i)
        }
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
            
        }
    }
    
    // Keep track of checked rows for a quicker download
    // Worst case would be half checked/half unchecked.
    var checkedCells:Dictionary<Int,Project> = [:]
}

extension ContentViewController : NSTableViewDelegate {
    
    @objc func checkBoxClicked(_ button: DSCheckBox) {
        if button.state == .off {
            self.checkedCells.removeValue(forKey: button.index)
        } else if button.state == .on {
            self.checkedCells[button.index] = button.project!
        }
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        if self.minorRelease == nil || row >= self.tableData.count{
            return nil
        }
        
        var cellValue = "(nil)"
        var idstr = "Col0"
        var checkbox_cell = false
        
        if tableView.tableColumns[0] == tableColumn {
            // checkbox
            checkbox_cell = true
        } else if tableView.tableColumns[1] == tableColumn {
            // project name
            cellValue = self.tableData[row].projectName
            idstr = "Col1"
        } else if tableView.tableColumns[2] == tableColumn {
            // project version
            cellValue = self.tableData[row].projectRelease.originalVersionString()
            idstr = "Col2"
        } else if tableView.tableColumns[3] == tableColumn {
            // project arch
            cellValue = "x86"
            idstr = "Col3"
        }

        if let cellView = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: idstr), owner: nil) {
            if checkbox_cell {
                if let cell = cellView as? DSCheckBox {
                    // if we don't have a URL disable the checkbox and uncheck it.
                    if self.tableData[row].archiveUrl == nil {
                        cell.state = .off
                        cell.isEnabled = false
                    } else {
                        self.checkedCells[row] = self.tableData[row]
                        cell.target = self
                        cell.action = #selector(self.checkBoxClicked(_:))
                        cell.index = row
                        cell.project = self.tableData[row]
                    }
                    return cell
                }
            } else {
                if let cell = cellView as? NSTableCellView {
                    cell.textField?.stringValue = cellValue
                    return cell
                }
            }
        }
        return nil
    }
}


extension ContentViewController : NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return tableData.count
    }
    
    func tableView(_ tableView: NSTableView, sortDescriptorsDidChange oldDescriptors: [NSSortDescriptor]) {
      // 1
//      guard let sortDescriptor = tableView.sortDescriptors.first else {
//        return
//      }
//      if let order =  {
//        // 2
//        sortOrder = order
//        sortAscending = sortDescriptor.ascending
//        reloadFileList()
//      }
        return
    }
}
//extension ContentViewController: NSSplitViewDelegate{
//    func splitView(_ splitView: NSSplitView, effectiveRect proposedEffectiveRect: NSRect, forDrawnRect  drawnRect: NSRect, ofDividerAt dividerIndex: Int) -> NSRect {
//        return .zero
//    }
//}
