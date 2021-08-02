//
//  Tetra.swift
//  Tetra
//
//  Created by Zerui Chen on 14/7/20.
//

import Foundation

/// The top most logial container for Tetra apis.
public class Tetra: ObservableObject {
    
    private init() {}
    
    /// Array of all ongoing tasks.
    @Published public var allTasks = [TTask]()
    
    /// Dictionary of task id to task.
    @Published public var tasksMap = [String:TTask]()
    
    /// Returns the download task associated with this id, creating one if necessary.
    public func downloadTask(forId id: String, dstURL: URL) -> TTask {
        if let task = tasksMap[id] {
            return task
        }
        // Create new task.
        let newTask = TTask(id: id, dstURL: dstURL)
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

extension Tetra {
    
    /// The only instance of Tetra ever created.
    public static let shared = Tetra()
    
}
