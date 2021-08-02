//
//  TTask.swift
//  Tetra
//
//  Created by Zerui Chen on 14/7/20.
//

import Combine

/// Class representing a download task.
public class TTask: ObservableObject {
    
    // MARK: Private Properties
    
    private var remoteURL: URL!
    
    private var dstURL: URL
    
    private var onSuccess: (()-> Void)!
    
    /// The underlying download task object.
    private var downloadTask: URLSessionDownloadTask!
    
    /// The resume data, if applicable.
    private var resumeData: Data?
    
    /// Property keeping track of whether this task was paused.
    private var isPaused = false
    
    private var progressObservation: NSKeyValueObservation?
    
    // MARK: Init
    
    /// Init a partial TTask, more information needs to be provided by calling .download before download starts.
    init(id: String, dstURL: URL) {
        self.id = id
        self.dstURL = dstURL
        
        // Check if already downloaded.
        if FileManager.default.fileExists(atPath: dstURL.path) {
            self.state = .success
        }
    }
    
    // MARK: Private API
    
    /// Callback for when task completes.
    private lazy var onTaskCompleted = { [weak self] (_ url: URL?, _ res: URLResponse?, _ error: Error?) in
        DispatchQueue.main.async {
            guard let self = self else {
                return
            }
            
            if error != nil {
                self.state = self.isPaused ? .paused : .failure(error!)
            }
            else {
                // Downloaded, try moving to destination.
                do {
                    // Remove existing item.
                    if FileManager.default.fileExists(atPath: self.dstURL.path) {
                        try FileManager.default.removeItem(at: self.dstURL)
                    }
                    try FileManager.default.moveItem(at: url!, to: self.dstURL)
                    // Update state and call success callback.
                    self.state = .success
                    self.onSuccess()
                }
                catch {
                    self.state = .failure(error)
                }
            }
        }
    }
    
    /// Create a new URLSessionDownloadTask.
    private func createTask() {
        if let resumeData = resumeData {
            downloadTask = URLSession.tetra.downloadTask(withResumeData: resumeData, completionHandler: onTaskCompleted)
        }
        else {
            downloadTask = URLSession.tetra.downloadTask(with: remoteURL, completionHandler: onTaskCompleted)
        }
        downloadTask.resume()
        
        // Observe progress of task when running.
        progressObservation = downloadTask.progress.observe(\.fractionCompleted) { (progress, fraction) in
            DispatchQueue.main.async {
                self.state = .downloading(progress.fractionCompleted)
            }
        }
    }
    
    // MARK: Public API
    
    /// Provide complete download information and begin a new download task.
    public func download(_ url: URL, onSuccess handler: @escaping ()-> Void) {
        self.remoteURL = url
        self.onSuccess = handler
        createTask()
    }
    
    public enum State {
        case downloading(Double), success, failure(Error), paused
    }
    
    /// Publisher for the download state.
    @Published public var state: State = .paused {
        didSet {
            // Here we update simpleState accordingly.
            let newSState: SimpleState.State
            switch state {
            case .downloading(_):
                newSState = .downloading
            case .failure(_):
                newSState = .none
            case .paused:
                newSState = .downloading
            case .success:
                newSState = .downloaded
            }
            // Write only if the value changed.
            if newSState != simpleState.value {
                simpleState.value = newSState
            }
        }
    }
    
    /// A unique id attached to each task.
    public let id: String
    
    // Simplified State to minimize update cost.
    public class SimpleState: ObservableObject {
        
        public enum State: Equatable {
            case none, downloading, downloaded
        }
        
        @Published public var value: State = .none
    }
    
    /// A simplified, observable state object that is updated by the main state.
    public let simpleState = SimpleState()
    
    /// Pause the task.
    public func pause() {
        isPaused = true
        downloadTask.cancel { (resumeData) in
            self.resumeData = resumeData
        }
    }
    
    /// Resume the task.
    public func resume() {
        if !isPaused {
            return
        }
        
        isPaused = false
        createTask()
    }
    
    /// Cancel the task.
    func cancel() {
        downloadTask.cancel()
    }
    
}

// MARK: Equatable
extension TTask: Equatable {
    public static func ==(_ lhs: TTask, _ rhs: TTask) -> Bool {
        lhs.dstURL == rhs.dstURL &&
            lhs.remoteURL == rhs.remoteURL
    }
}
