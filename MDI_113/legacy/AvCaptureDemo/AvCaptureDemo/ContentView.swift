
import SwiftUI
import AVFoundation

// MARK: - Camera Controller
class CameraViewController: UIViewController {
    private let session = AVCaptureSession()
    private let photoOutput = AVCapturePhotoOutput()
    private let movieOutput = AVCaptureMovieFileOutput()
    var onPhotoCaptured: ((UIImage?) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSession()
    }
    
    private func setupSession() {
        session.sessionPreset = .high
        
        // Camera input
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let cameraInput = try? AVCaptureDeviceInput(device: camera) else { return }
        
        // Microphone input
        guard let mic = AVCaptureDevice.default(for: .audio),
              let micInput = try? AVCaptureDeviceInput(device: mic) else { return }
        
        // Add inputs
        if session.canAddInput(cameraInput) { session.addInput(cameraInput) }
        if session.canAddInput(micInput) { session.addInput(micInput) }
        
        // Add outputs
        if session.canAddOutput(photoOutput) { session.addOutput(photoOutput) }
        if session.canAddOutput(movieOutput) { session.addOutput(movieOutput) }
        
        // Preview
        let preview = CameraPreview(frame: view.bounds)
        preview.setupPreview(session: session)
        view.addSubview(preview)
        
        session.startRunning()
    }
    
    func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    func startVideoRecording() {
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent("video.mov")
        movieOutput.startRecording(to: outputURL, recordingDelegate: self)
    }
    
    func stopVideoRecording() {
        movieOutput.stopRecording()
    }
}

extension CameraViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let data = photo.fileDataRepresentation(),
           let image = UIImage(data: data) {
            onPhotoCaptured?(image)
        }
    }
}

extension CameraViewController: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        print("Video saved at: \(outputFileURL)")
    }
}

// MARK: - Preview UIView
class CameraPreview: UIView {
    private var previewLayer: AVCaptureVideoPreviewLayer?
    
    func setupPreview(session: AVCaptureSession) {
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer?.videoGravity = .resizeAspectFill
        previewLayer?.frame = bounds
        if let layer = previewLayer {
            self.layer.addSublayer(layer)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        previewLayer?.frame = bounds
    }
}

// MARK: - SwiftUI Wrapper
struct CameraView: UIViewControllerRepresentable {
    @Binding var capturedImage: UIImage?
    @Binding var controller: CameraViewController?
    
    func makeUIViewController(context: Context) -> CameraViewController {
        let vc = CameraViewController()
        vc.onPhotoCaptured = { image in
            capturedImage = image
        }
        controller = vc
        return vc
    }
    
    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {}
}

// MARK: - Main UI
struct ContentView: View {
    @State private var capturedImage: UIImage?
    @State private var controller: CameraViewController?
    @State private var isRecordingVideo = false
    
    var body: some View {
        VStack {
            CameraView(capturedImage: $capturedImage, controller: $controller)
                .frame(height: 300)
            
            HStack(spacing: 20) {
                Button("Capture Photo") {
                    controller?.capturePhoto()
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
                
                Button(isRecordingVideo ? "Stop Video" : "Record Video") {
                    if isRecordingVideo {
                        controller?.stopVideoRecording()
                    } else {
                        controller?.startVideoRecording()
                    }
                    isRecordingVideo.toggle()
                }
                .padding()
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            
            if let image = capturedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                    .padding()
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}

