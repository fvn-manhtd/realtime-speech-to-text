/*
 See LICENSE folder for this sample's licensing information.
 */

import SwiftUI

struct MeetingTimerView: View {
    let speakers: [ScrumTimer.Speaker]
    let isRecording: Bool
    let theme: Theme
    
    private var currentSpeaker: String {
        speakers.first(where: { !$0.isCompleted })?.name ?? "Someone"
    }
    
    var body: some View {
        HStack(spacing: 20) {
            VStack(alignment: .leading) {
                Text(currentSpeaker)
                    .font(.headline)
                    .lineLimit(1)
                Text("is speaking")
                    .font(.subheadline)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 15) {
                Image(systemName: isRecording ? "mic" : "mic.slash")
                    .font(.title2)
                    .foregroundStyle(theme.accentColor)
                    .accessibilityLabel(isRecording ? "with transcription" : "without transcription")
                
                Circle()
                    .strokeBorder(lineWidth: 12)
                    .frame(width: 40, height: 40)
                    .overlay {
                        ForEach(speakers) { speaker in
                            if speaker.isCompleted, let index = speakers.firstIndex(where: { $0.id == speaker.id }) {
                                SpeakerArc(speakerIndex: index, totalSpeakers: speakers.count)
                                    .rotation(Angle(degrees: -90))
                                    .stroke(theme.mainColor, lineWidth: 6)
                            }
                        }
                    }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}

struct MeetingTimerView_Previews: PreviewProvider {
    static var speakers: [ScrumTimer.Speaker] {
        [ScrumTimer.Speaker(name: "Bill", isCompleted: true), ScrumTimer.Speaker(name: "Cathy", isCompleted: false)]
    }
    
    static var previews: some View {
        MeetingTimerView(speakers: speakers, isRecording: true, theme: .yellow)
    }
}
