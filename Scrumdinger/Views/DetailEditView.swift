/*
 See LICENSE folder for this sample's licensing information.
 */

import SwiftUI

struct DetailEditView: View {
    @Binding var scrum: DailyScrum
    @State private var newAttendeeName = ""

    var body: some View {
        Form {
            Section {
                TextField(String(localized: "Title"), text: $scrum.title)
                // HStack {
                //     Slider(value: $scrum.lengthInMinutesAsDouble, in: 5...30, step: 1) {
                //         Text("Length")
                //     }
                //     .accessibilityValue("\(scrum.lengthInMinutes) minutes")
                //     Spacer()
                //     Text("\(scrum.lengthInMinutes) minutes")
                //         .accessibilityHidden(true)
                // }
                ThemePicker(selection: $scrum.theme)
                Picker(String(localized: "Language"), selection: $scrum.language) {
                    ForEach(DailyScrum.availableLanguages, id: \.1) { language in
                        Text(language.0)
                            .tag(language.1)
                    }
                }
            } header: {
                Text(String(localized: "Meeting_Info"))
            }
        }
    }
}

struct DetailEditView_Previews: PreviewProvider {
    static var previews: some View {
        DetailEditView(scrum: .constant(DailyScrum.sampleData[0]))
    }
}
