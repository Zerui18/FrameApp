//
//  Tetra.swift
//  Tetra
//
//  Created by Zerui Chen on 14/7/20.
//

import Foundation
import UIKit

/// The top most logial container for Tetra apis.
public class Tetra: NSObject, ObservableObject {
    
    override public init() {
        super.init()
        NSLog("[Tetra] Created default session")
        self.session = .init(configuration: .default, delegate: self, delegateQueue: .main)
        NotificationCenter.default.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: nil) { _ in
            self.allTasks.forEach { $0.pause() }
        }
        NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: nil) { _ in
            self.allTasks.filter(\.canResume).forEach { $0.resume() }
        }
//        self.session = URLSession(configuration: .background(withIdentifier: "com.zx02.tetra"), delegate: self, delegateQueue: .main)
    }
        
    /// The URLSession that is used by this instance.
    private(set) var session: URLSession!
    
    /// Array of all ongoing tasks.
    @Published public private(set) var allTasks = [TTask]()
    
    /// Dictionary of task id to task.
    @Published public private(set) var tasksMap = [String:TTask]()
    
    /// Returns the download task associated with this id, creating one if necessary.
    public func downloadTask(forId id: String, dstURL: URL) -> TTask {
        if let task = tasksMap[id] {
            return task
        }
        // Create new task.
        let newTask = TTask(session: session, id: id, dstURL: dstURL)
        tasksMap[id] = newTask
        allTasks.append(newTask)
        return newTask
    }
    
    /// Removes a download task.
    public func remove(task: TTask) {
        // Remove from array.
        if let idx = allTasks.firstIndex(of: task) {
            let task = allTasks.remove(at: idx)
            task.cancel()
        }
        // Remove from map.
        tasksMap[task.id] = nil
    }
    
}

extension Tetra: URLSessionDownloadDelegate {
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard let task = allTasks.first(where: { $0.downloadTask === downloadTask }) else { return }
        do {
            // Remove existing item.
            if FileManager.default.fileExists(atPath: task.dstURL.path) {
                try FileManager.default.removeItem(at: task.dstURL)
            }
            try FileManager.default.moveItem(at: location, to: task.dstURL)
            // Update state and call success callback.
            task.state = .success
            task.onSuccess()
        }
        catch {
            task.state = .failure(error)
        }
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let task = allTasks.first(where: { $0.downloadTask === task }) else { return }
        if !task.isPaused && error != nil {
            task.resumeData = (error! as NSError).userInfo[NSURLSessionDownloadTaskResumeData] as? Data
            task.state = task.isPaused ? .paused : .failure(error!)
        }
    }
    
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        guard let task = allTasks.first(where: { $0.downloadTask === downloadTask }) else { return }
        task.state = .downloading(Double(totalBytesWritten) / Double(totalBytesExpectedToWrite))
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
        completionHandler(request)
    }
    
}

extension Tetra {
    
    /// The only instance of Tetra ever created.
    public static let shared = Tetra()
    
}
