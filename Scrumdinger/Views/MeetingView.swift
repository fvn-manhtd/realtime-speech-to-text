/*
 See LICENSE folder for this sample's licensing information.
 */

import SwiftUI
import AVFoundation

struct MeetingView: View {
    @Binding var scrum: DailyScrum
    @StateObject var scrumTimer = ScrumTimer()
    @StateObject private var speechRecognizer = SpeechRecognizer()
    @State private var isRecording = false
    @State private var speakerTranscripts: [SpeakerTranscript] = []
    @State private var showAlert = false
    
    private var player: AVPlayer { AVPlayer.sharedDingPlayer }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Row 2: Transcript (80% height)
                ScrollView {
                    ScrollViewReader { scrollView in
                        VStack(alignment: .leading, spacing: 16) {
                            ForEach(speakerTranscripts) { transcript in
                                VStack(alignment: .leading, spacing: 16) {
                                    HStack {
                                        Text(transcript.speakerName)
                                            .font(.headline)
                                            .foregroundColor(Color.primary)
                                        Text(String(localized: "is_speaking"))
                                            .font(.subheadline)
                                            .foregroundColor(Color.primary)
                                    }
                                    
                                    Text(transcript.text)
                                        .font(.body)
                                        .foregroundColor(Color.primary) // Adjust text color based on mode
                                        .padding(.leading)
                                }
                            }
                            
                            // Only show current transcript if we're recording
                            if isRecording && !speechRecognizer.transcript.isEmpty {
                                VStack(alignment: .leading, spacing: 16) {
                                    HStack {
                                        Text(scrumTimer.activeSpeaker)
                                            .font(.headline)
                                            .foregroundColor(Color.primary)
                                        Text(String(localized: "is_speaking"))
                                            .font(.subheadline)
                                            .foregroundColor(Color.primary)
                                    }
                                    
                                    Text(speechRecognizer.transcript)
                                        .font(.body)
                                        .foregroundColor(Color.primary) // Adjust text color based on mode
                                        .padding(.leading)
                                }
                                .id("currentTranscript") // Add an ID to scroll to
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 16.0)
                                .fill(scrum.theme.mainColor.opacity(0.2))
                        )
                        .onChange(of: speechRecognizer.transcript) { _ in
                            // Scroll to bottom when transcript changes
                            withAnimation {
                                scrollView.scrollTo("currentTranscript", anchor: .bottom)
                            }
                        }
                        .onChange(of: speakerTranscripts.count) { _ in
                            // Scroll to bottom when new transcript is added
                            withAnimation {
                                scrollView.scrollTo("currentTranscript", anchor: .bottom)
                            }
                        }
                    }
                }
                .frame(height: geometry.size.height * 0.80)
                .padding(10)

                // Row 1: Meeting UI (20% height)
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(UIColor.systemBackground))
                    HStack {
                        Spacer()
                        
                        // Next Speaker Button
                        Button(action: {
                            Task {
                                if isRecording {
                                    if !speechRecognizer.transcript.isEmpty {
                                        speakerTranscripts.append(
                                            SpeakerTranscript(
                                                speakerName: scrumTimer.activeSpeaker,
                                                text: speechRecognizer.transcript,
                                                timestamp: Date()
                                            )
                                        )
                                        speechRecognizer.resetTranscript()
                                    }
                                    speechRecognizer.stopTranscribing()
                                    isRecording = false
                                }
                                
                                scrumTimer.skipSpeaker()
                                
                                speechRecognizer.startTranscribing()
                                isRecording = true
                            }
                        }) {
                            VStack {
                                Image(systemName: "forward.fill")
                                    .resizable()
                                    .frame(width: 24, height: 24)
                                    .foregroundColor(Color(UIColor.label)) // Adjust color based on mode
                            }
                        }
                        .padding(.trailing, 10)
                        .disabled(scrum.attendees.count <= 1) // Disable button if there is only 1 attendee
                        
                        Spacer()
                        
                        // Recording Button
                        Button(action: toggleRecording) {
                            Image(systemName: isRecording ? "stop.circle.fill" : "mic.circle.fill")
                                .resizable()
                                .frame(width: 70, height: 70)
                                .foregroundColor(isRecording ? .red : .black)
                                .background(
                                    Circle()
                                        .fill(Color.white)
                                )
                        }
                        
                        Spacer()
                        
                        // AI Button
                        Button(action: {
                            showAlert = true
                        }) {
                            VStack {
                                Image(systemName: "brain.head.profile")
                                    .resizable()
                                    .frame(width: 24, height: 24)
                                    .foregroundColor(Color(UIColor.label)) // Adjust color based on mode
                            }
                        }
                        .padding(.trailing, 10)
                        .alert(isPresented: $showAlert) {
                            Alert(
                                title: Text("AI Button Pressed"),
                                message: Text("You have pressed the AI button."),
                                dismissButton: .default(Text("OK"))
                            )
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                }
                .frame(maxWidth: .infinity)
                .frame(height: geometry.size.height * 0.15)
                .padding(.top, 10)
                .padding(.bottom, 10)
            }
            .foregroundColor(scrum.theme.accentColor)
        }
        .onAppear {
            speechRecognizer.setLanguage(scrum.language)
            startScrum()
        }
        .onDisappear {
            endScrum()
        }
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: scrum.language) { newLanguage in
            speechRecognizer.setLanguage(newLanguage)
        }
    }
    
    private func toggleRecording() {
        if isRecording {
            // Only save transcript when stopping recording
            if !speechRecognizer.transcript.isEmpty {
                speakerTranscripts.append(
                    SpeakerTranscript(
                        speakerName: scrumTimer.activeSpeaker,
                        text: speechRecognizer.transcript,
                        timestamp: Date()
                    )
                )
                // Clear the transcript immediately after saving
                speechRecognizer.resetTranscript()
            }
            speechRecognizer.stopTranscribing()
        } else {
            // Only reset the transcript, keep previous speakerTranscripts
            speechRecognizer.resetTranscript()
            speechRecognizer.startTranscribing()
        }
        isRecording.toggle()
    }
    
    private func startScrum() {
        guard !scrum.attendees.isEmpty else {
            print("Error: No attendees available.")
            return
        }
        scrumTimer.reset(lengthInMinutes: scrum.lengthInMinutes, attendees: scrum.attendees)
        scrumTimer.speakerChangedAction = {
            // Just play sound on speaker change, don't save transcript
            player.seek(to: .zero)
            player.play()
        }
        scrumTimer.startScrum()
    }
    
    private func endScrum() {
        scrumTimer.stopScrum()
        speechRecognizer.stopTranscribing()
        
        // Save final transcript only if we haven't already saved it
        if isRecording && !speechRecognizer.transcript.isEmpty {
            speakerTranscripts.append(
                SpeakerTranscript(
                    speakerName: scrumTimer.activeSpeaker,
                    text: speechRecognizer.transcript,
                    timestamp: Date()
                )
            )
        }
        
        isRecording = false
        
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
        speechRecognizer.resetTranscript()
    }
}

struct MeetingView_Previews: PreviewProvider {
    static var previews: some View {
        // Ensure sampleData is not empty
        if let firstScrum = DailyScrum.sampleData.first {
            MeetingView(scrum: .constant(firstScrum))
        } else {
            Text("No sample data available")
        }
    }
}
