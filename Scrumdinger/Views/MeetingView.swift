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
    @State private var speakerTranscripts: [SpeakerTranscript] = []
    
    private var player: AVPlayer { AVPlayer.sharedDingPlayer }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Row 1: Meeting UI (20% height)
                ZStack {
                    RoundedRectangle(cornerRadius: 16.0)
                        .fill(scrum.theme.mainColor)
                    VStack(spacing: 0) {                    
                        // Add recording control button
                        Button(action: toggleRecording) {
                            Image(systemName: isRecording ? "stop.circle.fill" : "mic.circle.fill")
                                .resizable() // Make the image resizable
                                .frame(width: 40, height: 40) // Set the size of the button
                                .foregroundColor(isRecording ? .red : scrum.theme.accentColor)
                        }
                        .padding(.vertical, 1)
                    }
                }
                .frame(height: geometry.size.height * 0.2) // 20% of screen height
                .padding(.top, 20)
                .padding(.bottom, 20) 
                
                
                // Row 2: Transcript (80% height)
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        ForEach(speakerTranscripts) { transcript in
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Speaking:")
                                    .font(.headline)
                                    .foregroundColor(scrum.theme.accentColor)
                                
                                Text(transcript.text)
                                    .font(.body)
                                    .padding(.leading)
                            }
                        }
                        
                        // Show current speaker's transcript
                        if !speechRecognizer.transcript.isEmpty {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Speaking:")
                                    .font(.headline)
                                    .foregroundColor(scrum.theme.accentColor)
                                
                                Text(speechRecognizer.transcript)
                                    .font(.body)
                                    .padding(.leading)
                            }
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 16.0)
                            .fill(scrum.theme.mainColor.opacity(0.2))
                    )
                }
                .frame(height: geometry.size.height * 0.75)
                .padding(.top, 8)
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
    
    private func toggleRecording() {
        if isRecording {
            // Save current transcript before stopping
            if !speechRecognizer.transcript.isEmpty {
                speakerTranscripts.append(
                    SpeakerTranscript(
                        speakerName: scrumTimer.activeSpeaker,
                        text: speechRecognizer.transcript,
                        timestamp: Date()
                    )
                )
            }
            speechRecognizer.stopTranscribing()
        } else {
            // Clear the transcript when starting new recording
            speechRecognizer.resetTranscript()
            speechRecognizer.startTranscribing()
        }
        isRecording.toggle()
    }
    
    private func startScrum() {
        scrumTimer.reset(lengthInMinutes: scrum.lengthInMinutes, attendees: scrum.attendees)
        scrumTimer.speakerChangedAction = {
            // Save current speaker's transcript if not empty
            if !speechRecognizer.transcript.isEmpty {
                let currentSpeaker = scrumTimer.activeSpeaker
                speakerTranscripts.append(
                    SpeakerTranscript(
                        speakerName: currentSpeaker,
                        text: speechRecognizer.transcript,
                        timestamp: Date()
                    )
                )
            }
            
            // Reset transcript for next speaker
            speechRecognizer.resetTranscript()
            
            // Play sound
            player.seek(to: .zero)
            player.play()
        }
        scrumTimer.startScrum()
    }
    
    private func endScrum() {
        scrumTimer.stopScrum()
        speechRecognizer.stopTranscribing()
        isRecording = false
        
        // Save final speaker's transcript
        if !speechRecognizer.transcript.isEmpty {
            let currentSpeaker = scrumTimer.activeSpeaker
            speakerTranscripts.append(
                SpeakerTranscript(
                    speakerName: currentSpeaker,
                    text: speechRecognizer.transcript,
                    timestamp: Date()
                )
            )
        }
        
        // Combine all transcripts for history
        let fullTranscript = speakerTranscripts
            .map { "\($0.speakerName): \($0.text)" }
            .joined(separator: "\n\n")
        
        let newHistory = History(
            attendees: scrum.attendees,
            transcript: fullTranscript
        )
        scrum.history.insert(newHistory, at: 0)
        
        // Clear transcripts
        speakerTranscripts = []
    }
}

struct MeetingView_Previews: PreviewProvider {
    static var previews: some View {
        MeetingView(scrum: .constant(DailyScrum.sampleData[0]))
    }
}
