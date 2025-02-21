/*
 See LICENSE folder for this sample's licensing information.
 */

import Foundation

struct SpeakerTranscript: Identifiable {
    let id = UUID()
    let speakerName: String
    let text: String
    let timestamp: Date
} 