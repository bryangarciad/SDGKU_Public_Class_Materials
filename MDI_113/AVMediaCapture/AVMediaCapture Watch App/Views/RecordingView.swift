import SwiftUI

struct RecordingView: View {
    @ObservedObject var audioManger: AudioManager
    
    var body: some View {
        VStack(spacing: 12) {
            RecordingIndicator(
                isRecording: audioManger.isRecording,
                time: audioManger.recordingTime
            )
        }
    }
}

struct RecordingIndicator: View {
    let isRecording: Bool
    let time: TimeInterval
    
    @State private var isPulsing: Bool = false
    
    private var timeString: String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(
                        isRecording ? Color.red.opacity(0.2) : Color.gray.opacity(0.2)
                    )
                    .frame(width: 80, height: 80)
                    .scaleEffect(isPulsing && isRecording ? 1.2 : 1.0)
                
                Image(systemName: isRecording ? "waveform" : "mic.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(isRecording ? .red : .gray)
            }
            .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: isPulsing)
            
            if isRecording {
                Text("")
            }
        }
    }
    
}

#Preview {
    RecordingView(audioManger: AudioManager())
}
