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
    
    private let session: URLSession
    
    private var remoteURL: URL!
    
    let dstURL: URL
    
    var onSuccess: (()-> Void)!
    
    var canResume: Bool {
        isPaused && remoteURL != nil
    }
    
    /// The underlying download task object.
    var downloadTask: URLSessionDownloadTask?
    
    private var resumeDataTemporaryFile: URL {
        URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("zx02.tetra.\(id).resume")
    }
    
    /// The resume data, if applicable.
    var resumeData: Data? {
        set {
            do {
                try newValue?.write(to: resumeDataTemporaryFile)
            }
            catch {
                NSLog("[Tetra] error setting resume data \(error)")
            }
        }
        get {
            try? Data(contentsOf: resumeDataTemporaryFile)
        }
    }
    
    /// Property keeping track of whether this task was paused.
    var isPaused = false
        
    // MARK: Init
    
    /// Init a partial TTask, more information needs to be provided by calling .download before download starts.
    init(session: URLSession, id: String, dstURL: URL) {
        self.session = session
        self.id = id
        self.dstURL = dstURL
        
        // Check if already downloaded.
        if FileManager.default.fileExists(atPath: dstURL.path) {
            self.state = .success
        }
    }
    
    // MARK: Private API
    
    /// Create a new URLSessionDownloadTask.
    private func createTask() {
        downloadTask?.cancel()
        if let resumeData = resumeData {
            downloadTask = session.downloadTask(withResumeData: resumeData)
        }
        else {
            var request = URLRequest(url: remoteURL)
            request.setValue("okhttp/3.10.0", forHTTPHeaderField: "User-Agent")
            downloadTask = session.downloadTask(with: request)
        }
        
        state = .preparing
        downloadTask!.resume()
    }
    
    // MARK: Public API
    
    /// Provide complete download information and begin a new download task.
    public func download(_ url: URL, onSuccess handler: @escaping ()-> Void) {
        self.remoteURL = url
        self.onSuccess = handler
        createTask()
    }
    
    public enum State {
        case downloading(Double), success, failure(Error), paused, preparing
    }
    
    /// Publisher for the download state.
    @Published public internal(set) var state: State = .paused
    
    /// A unique id attached to each task.
    public let id: String
    
    /// Pause the task.
    public func pause() {
        isPaused = true
        downloadTask?.cancel { self.resumeData = $0 }
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
        downloadTask?.cancel()
    }
    
}

// MARK: Equatable
extension TTask: Equatable {
    public static func ==(_ lhs: TTask, _ rhs: TTask) -> Bool {
        lhs.dstURL == rhs.dstURL &&
            lhs.remoteURL == rhs.remoteURL
    }
}
