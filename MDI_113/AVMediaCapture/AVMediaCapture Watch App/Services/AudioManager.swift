import Foundation
import Combine
import AVFoundation
import WatchKit

class AudioManager: NSObject, ObservableObject {
    
    // MARK: - Published Variables
    @Published var recordings: [VoiceMemo] = []
    
    @Published var isRecording = false
    @Published var isPlaying = false
    @Published var recordingTime: TimeInterval = 0
    @Published var currentlyPLaying: URL?
    @Published var hasPermission = false
    @Published var errorMessage: String?
    
    // MARK: - Private Properties
    private var audioRecorder: AVAudioRecorder?
    private var audioPlayer: AVAudioPlayer?
    private var recordingTimer: Timer?
    
    private let recordingSettings: [String: Any] = [
        AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
        AVSampleRateKey: 44100,
        AVNumberOfChannelsKey: 1,
        AVEncoderAudioQualityKey: AVAudioQuality.medium.rawValue
    ]
    
    override init() {
        super.init()
        loadRecordings()
    }
    
    
    // MARK: - Recording Code
    func startRecording() {
        guard hasPermission else {
            errorMessage = "Microphone permissions required -- App can't run without mic permission"
            return
        }
        
        let filename = "memo_\(Int(Date().timeIntervalSince1970)).m4a"
        let url = getUserDocumentDirectory().appendingPathComponent(filename)
        
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord, mode: .default)
            try session.setActive(true)
            
            audioRecorder = try AVAudioRecorder(url: url, settings: recordingSettings)
            audioRecorder?.record()
            
            isRecording = true
            recordingTime = 0
            startTimer()
        } catch {
            errorMessage = "Failed to record audio: \(error.localizedDescription)"
        }
    }
    
    func loadRecordings() {
        let documentsURL = getUserDocumentDirectory()
        
        do {
            let files = try FileManager.default.contentsOfDirectory(
                at: documentsURL,
                includingPropertiesForKeys: [.creationDateKey],
                options: .skipsHiddenFiles
            )
            
            recordings = files
                .filter { $0.pathExtension == "m4a"}
                .compactMap { url -> VoiceMemo? in
                    let attributes = try? FileManager.default.attributesOfItem(atPath: url.path())
                    let createdAt = attributes?[.creationDate]  as? Date ?? Date()
                    
                    let asset = AVURLAsset(url: url)
                    let duration = CMTimeGetSeconds(asset.duration)
                    
                    return VoiceMemo(url: url, createdAt: createdAt, duration: duration)
                }
                .sorted { $0.createdAt > $1.createdAt }
        } catch {
            errorMessage = "Failed to record audio: \(error.localizedDescription)"
        }
    }
    
    func stopRecording() {
        audioRecorder?.stop()
        stopTimer()
        isRecording = false
        
        if let url = audioRecorder?.url {
            let memo = VoiceMemo(
                url: url,
                createdAt: Date(),
                duration: recordingTime
            )
            
            recordings.insert(memo, at: 0)
        }
        
        audioRecorder = nil
    }
    // MARK: - Playback Methods
    func play(memo: VoiceMemo) {
        // Stop any other recording that may be in play
        stop()
        
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default)
            try session.setActive(true)
            
            audioPlayer = try AVAudioPlayer(contentsOf: memo.url)
            audioPlayer?.delegate = self
            audioPlayer?.play()
            
            isPlaying = true
            currentlyPLaying = memo.url
        } catch {
            errorMessage = "Playback failed"
        }
    }
    
    func stop () {
        audioPlayer?.stop()
        audioPlayer = nil
        isPlaying = false
        currentlyPLaying = nil
    }
    
    // MARK: - File Management
    func deleteRecording(_ memo: VoiceMemo) {
        do {
            try FileManager.default.removeItem(at: memo.url)
            recordings.removeAll { $0.url == memo.url }
        } catch {
            errorMessage = "Failed To Delete File"
        }
        
    }
    
    // MARK: - Helpers
    func getUserDocumentDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    private func startTimer() {
        recordingTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.recordingTime += 1
        }
    }
    
    private func stopTimer() {
        recordingTimer?.invalidate()
        recordingTimer = nil
    }
    
    
    // MARK: - Permission
    func requestPermission() async {
        let permissionGranted = await AVAudioApplication.requestRecordPermission()
        
        DispatchQueue.main.async {
            self.hasPermission = permissionGranted
        }
    }
}

extension AudioManager: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        DispatchQueue.main.async {
            self.isPlaying = false
            self.currentlyPLaying = nil
        }
    }
}
