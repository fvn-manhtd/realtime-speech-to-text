/*
 See LICENSE folder for this sample's licensing information.
 */

import SwiftUI
import AVFoundation

struct MeetingView: View {
    @Binding var scrum: DailyScrum
    @StateObject var scrumTimer = ScrumTimer()
    @StateObject var speechRecognizer = SpeechRecognizer()
    @State private var isRecording = false
    
    private var player: AVPlayer { AVPlayer.sharedDingPlayer }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 12) {
                // Row 1: Meeting UI (20% height)
                ZStack {
                    RoundedRectangle(cornerRadius: 16.0)
                        .fill(scrum.theme.mainColor)
                    VStack {
                        MeetingHeaderView(secondsElapsed: scrumTimer.secondsElapsed, 
                                        secondsRemaining: scrumTimer.secondsRemaining, 
                                        theme: scrum.theme)
                        MeetingTimerView(speakers: scrumTimer.speakers, 
                                       isRecording: isRecording, 
                                       theme: scrum.theme)
                        MeetingFooterView(speakers: scrumTimer.speakers, 
                                        skipAction: scrumTimer.skipSpeaker)
                    }
                }
                .frame(height: geometry.size.height * 0.2) // 20% of screen height
                
                // Row 2: Transcript (80% height)
                ScrollView {
                    Text(speechRecognizer.transcript)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 16.0)
                                .fill(scrum.theme.mainColor.opacity(0.2))
                        )
                }
                .frame(height: geometry.size.height * 0.75) // 75% to account for spacing
            }
            .padding()
            .foregroundColor(scrum.theme.accentColor)
        }
        .onAppear {
            startScrum()
        }
        .onDisappear {
            endScrum()
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func startScrum() {
        scrumTimer.reset(lengthInMinutes: scrum.lengthInMinutes, attendees: scrum.attendees)
        scrumTimer.speakerChangedAction = {
            player.seek(to: .zero)
            player.play()
        }
        speechRecognizer.resetTranscript()
        speechRecognizer.startTranscribing()
        isRecording = true
        scrumTimer.startScrum()
    }
    
    private func endScrum() {
        scrumTimer.stopScrum()
        speechRecognizer.stopTranscribing()
        isRecording = false
        let newHistory = History(attendees: scrum.attendees,
                                 transcript: speechRecognizer.transcript)
        scrum.history.insert(newHistory, at: 0)
    }
}

struct MeetingView_Previews: PreviewProvider {
    static var previews: some View {
        MeetingView(scrum: .constant(DailyScrum.sampleData[0]))
    }
}
