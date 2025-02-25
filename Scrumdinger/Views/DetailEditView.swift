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
            Section(header: Text(String(localized: "Attendees"))) {
                ForEach(scrum.attendees) { attendee in
                    Text(attendee.name)
                }
                .onDelete { indices in
                    scrum.attendees.remove(atOffsets: indices)
                }
                HStack {
                    TextField(String(localized: "New_Attendee"), text: $newAttendeeName)
                    Button(action: {
                        withAnimation {
                            let attendee = DailyScrum.Attendee(name: newAttendeeName)
                            scrum.attendees.append(attendee)
                            newAttendeeName = ""
                        }
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .accessibilityLabel(String(localized: "Add_Attendee"))
                    }
                    .disabled(newAttendeeName.isEmpty)
                }
            }
        }
    }
}

struct DetailEditView_Previews: PreviewProvider {
    static var previews: some View {
        DetailEditView(scrum: .constant(DailyScrum.sampleData[0]))
    }
}
