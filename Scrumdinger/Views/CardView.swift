/*
 See LICENSE folder for this sample’s licensing information.
 */

import SwiftUI

struct CardView: View {
    let scrum: DailyScrum
    var body: some View {
        VStack(alignment: .leading) {
            Text(scrum.title)
                .font(.headline)
                .accessibilityAddTraits(.isHeader)
            Spacer()
            HStack {
                Label(DailyScrum.getLanguageDisplayName(for: scrum.language), systemImage: "globe")
                    .accessibilityLabel(String(localized: "Language: \(DailyScrum.getLanguageDisplayName(for: scrum.language))"))
                    .labelStyle(.trailingIcon)
                Spacer()
//                Label("\(scrum.lengthInMinutes)", systemImage: "clock")
//                    .accessibilityLabel("\(scrum.lengthInMinutes) minute meeting")
//                    .labelStyle(.trailingIcon)
            }
            .font(.caption)
        }
        .padding()
        .foregroundColor(scrum.theme.accentColor)
    }
}

struct CardView_Previews: PreviewProvider {
    static var scrum = DailyScrum.sampleData[0]
    static var previews: some View {
        CardView(scrum: scrum)
            .background(scrum.theme.mainColor)
            .previewLayout(.fixed(width: 400, height: 60))
    }
}
