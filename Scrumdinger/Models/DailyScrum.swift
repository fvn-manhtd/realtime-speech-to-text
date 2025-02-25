/*
 See LICENSE folder for this sample's licensing information.
 */

import Foundation

enum Language: String, CaseIterable, Identifiable {
    case english = "English"
    case spanish = "Spanish"
    case french = "French"
    case german = "German"
    
    var id: String { self.rawValue }
}

// Add this new struct before DailyScrum definition
struct ScrumLanguage: Codable, Identifiable {
    let name: String
    let code: String
    
    var id: String { code }
}

struct DailyScrum: Identifiable, Codable {
    let id: UUID
    var title: String
    var attendees: [Attendee]
    var lengthInMinutes: Int
    var lengthInMinutesAsDouble: Double {
        get {
            Double(lengthInMinutes)
        }
        set {
            lengthInMinutes = Int(newValue)
        }
    }
    var theme: Theme
    var history: [History] = []
    var language: String  // Stores language codes like "en", "fr", etc.
    
    init(id: UUID = UUID(), title: String, attendees: [String], lengthInMinutes: Int, theme: Theme, language: String = DailyScrum.availableLanguages[0].1) {
        self.id = id
        self.title = title
        self.attendees = attendees.map { Attendee(name: $0) }
        self.lengthInMinutes = lengthInMinutes
        self.theme = theme
        self.language = language
    }
}

extension DailyScrum {
    struct Attendee: Identifiable, Codable {
        let id: UUID
        var name: String
        
        init(id: UUID = UUID(), name: String) {
            self.id = id
            self.name = name
        }
    }
    
    static var emptyScrum: DailyScrum {
        DailyScrum(title: "", attendees: [], lengthInMinutes: 5, theme: .sky)
    }
}

extension DailyScrum {
    static let sampleData: [DailyScrum] = [
        DailyScrum(title: "Design", attendees: ["Cathy", "Dara", "John", "Lisa"], lengthInMinutes: 10, theme: .yellow, language: "en-US"),
    ]
}

extension DailyScrum {
    // Update language options to use ScrumLanguage struct
    static let availableLanguages: [(String, String)] = [
        ("English", "en-US"),
        ("Japanese", "ja-JP"),
        ("Vietnamese", "vi-VN"),
        ("Spanish", "es-ES"),
        ("French", "fr-FR"),
        ("German", "de-DE")
    ]
    
    // Helper function to get display name for a language code
    static func getLanguageDisplayName(for code: String) -> String {
        availableLanguages.first { $0.1 == code }?.0 ?? "English"
    }
}
