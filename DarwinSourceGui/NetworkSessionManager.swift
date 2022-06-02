//
//  NetworkSessionManager.swift
//  DarwinSourceGui
//
//  Created by John Othwolo on 5/17/21.
//  Copyright © 2021 PureDarwin. All rights reserved.
//

import Cocoa

class NetworkSessionManager: AsynchronousOperation {
    
    private var urlSession: URLSession?
    var downloadTask: URLSessionDownloadTask?
    private var project: Project
    private var destinationUrl: URL?
    
    
    init(withBackgroundSession: String, project: Project, destination_: URL?) {
        self.project = project
        super.init()
        let config = URLSessionConfiguration.background(withIdentifier: withBackgroundSession)
        config.isDiscretionary = true
        config.allowsCellularAccess = true
        urlSession = URLSession(configuration: config, delegate: self, delegateQueue: .main)
        
        if let url = destination_ {
            self.destinationUrl = url
        } else {
            self.destinationUrl = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first
        }
        downloadTask = urlSession?.downloadTask(with: project.archiveUrl!)
        downloadTask?.resume()
        defer { self.finish() }
    }
    
    init(project: Project, destination_: URL?) {
        self.project = project
        super.init()
        let config = URLSessionConfiguration.background(withIdentifier: (project.archiveUrl?.absoluteString)!)
        config.allowsCellularAccess = true
        urlSession = URLSession(configuration: config, delegate: self, delegateQueue: .main)
        
        if let url = destination_ {
            self.destinationUrl = url
        } else {
            self.destinationUrl = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first
        }
        downloadTask = urlSession?.downloadTask(with: project.archiveUrl!)
//        downloadTask?.resume()
    }
    
    private func setTask(){
        downloadTask = urlSession?.downloadTask(with: project.archiveUrl!)
        {   tempURL, response, error in
            
            defer { self.finish() }
            
            guard
                let httpResponse = response as? HTTPURLResponse,
                200..<300 ~= httpResponse.statusCode
            else {
                // handle invalid return codes however you'd like
                print("Download unexpectedly failed");
                return
            }

            guard let temporaryURL = tempURL, error == nil else {
                print(error ?? "Unknown error")
                return
            }
            
            do {
                print(self.project.archiveUrl!.lastPathComponent)
                let manager = FileManager.default
                let fullDestinationUrl = self.destinationUrl!.appendingPathComponent(self.project.archiveUrl!.lastPathComponent)
                
                try? manager.removeItem(at: fullDestinationUrl)                   // remove the old one, if any
                try manager.moveItem(at: temporaryURL, to: fullDestinationUrl)    // move new one there
            } catch let moveError {
                print("\(moveError)")
            }
        }
    }

    static func batchDownload(_ projects:Array<Project>, _ dest :URL?) -> OperationQueue {
        let queue: OperationQueue = {
            let _queue = OperationQueue()
            _queue.name = "Download_\(projects.randomElement()!.macMinorRelease.releaseName)"
            _queue.maxConcurrentOperationCount = 3    // I'd usually use values like 3 or 4 for performance reasons, but OP asked about downloading one at a time
            return _queue
        }()
        for project in projects {
            queue.addOperation(NetworkSessionManager(project:project, destination_: dest))
        }
        return queue
    }
    
    override func cancel() {
        downloadTask?.cancel()
        super.cancel()
    }
    
    override func main() {
        downloadTask?.resume()
        do { self.finish() }
    }
    
}

extension NetworkSessionManager: URLSessionDownloadDelegate, URLSessionDelegate {
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
//        print(downloadTask.response)
        print(project.archiveUrl!.lastPathComponent)
        //copy downloaded data to your downloads directory with same names as source file
        
        let fullDestinationUrl = destinationUrl!.appendingPathComponent(project.archiveUrl!.lastPathComponent)
//        print(fullDestinationUrl)
        let dataFromURL = NSData(contentsOf: location)
        dataFromURL?.write(to: fullDestinationUrl, atomically: true)
    }
    


    func urlSession(_ session: URLSession,
                downloadTask: URLSessionDownloadTask,
                didWriteData bytesWritten: Int64,
           totalBytesWritten: Int64,
           totalBytesExpectedToWrite: Int64) {
//        print("\(CGFloat(totalBytesWritten))Bytes downloaded")
        // ...
    }


    func urlSession(_ session: URLSession,
                    task: URLSessionTask,
                    didCompleteWithError error: Error?) {
        if let errorStr = error?.localizedDescription {
            print("Download completed with error: \(errorStr)");
        }
    }

}
