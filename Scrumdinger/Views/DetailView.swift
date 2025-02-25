/*
 See LICENSE folder for this sample's licensing information.
 */

import SwiftUI

struct DetailView: View {
    @Binding var scrum: DailyScrum
    @State private var editingScrum = DailyScrum.emptyScrum

    @State private var isPresentingEditView = false
    
    var body: some View {
        List {
            Section(header: Text("Meeting_Info")) {
                NavigationLink(destination: MeetingView(scrum: $scrum)) {
                    Label(String(localized: "Start_Meeting"), systemImage: "timer")
                        .font(.headline)
                        .foregroundColor(.accentColor)
                }
//                HStack {
//                    Label("Length", systemImage: "clock")
//                    Spacer()
//                    Text("\(scrum.lengthInMinutes) minutes")
//                }
                .accessibilityElement(children: .combine)
                HStack {
                    Label(String(localized: "Theme"), systemImage: "paintpalette")
                    Spacer()
                    Text(scrum.theme.name)
                        .padding(4)
                        .foregroundColor(scrum.theme.accentColor)
                        .background(scrum.theme.mainColor)
                        .cornerRadius(4)
                }
                .accessibilityElement(children: .combine)
                HStack {
                    Label(String(localized: "Language"), systemImage: "globe")
                    Spacer()
                    Text(DailyScrum.getLanguageDisplayName(for: scrum.language))
                }
                .accessibilityElement(children: .combine)
            }
            Section(header: Text(String(localized: "Attendees"))) {
                ForEach(scrum.attendees) { attendee in
                    Label(attendee.name, systemImage: "person")
                }
                .onDelete { indices in
                    scrum.attendees.remove(atOffsets: indices)
                }
            }
            Section(header: Text(String(localized: "History"))) {
                if scrum.history.isEmpty {
                    Label(String(localized: "No_meetings_yet"), systemImage: "calendar.badge.exclamationmark")
                }
                ForEach(scrum.history) { history in
                    NavigationLink(destination: HistoryView(history: history)) {
                        HStack {
                            Image(systemName: "calendar")
                            Text(history.date, style: .date)
                            Text(history.date, style: .time)
                        }
                    }
                }
                .onDelete(perform: deleteHistory)
            }
        }
        .navigationTitle(scrum.title)
        .toolbar {
            Button(String(localized: "Edit")) {
                isPresentingEditView = true
                editingScrum = scrum
            }
        }
        .sheet(isPresented: $isPresentingEditView) {
            NavigationStack {
                DetailEditView(scrum: $editingScrum)
                    .navigationTitle(scrum.title)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button(String(localized: "Cancel")) {
                                isPresentingEditView = false
                            }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button(String(localized: "Done")) {
                                isPresentingEditView = false
                                scrum = editingScrum
                            }
                        }
                    }
            }
        }
    }

    private func deleteHistory(at offsets: IndexSet) {
        scrum.history.remove(atOffsets: offsets)
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            DetailView(scrum: .constant(DailyScrum.sampleData[0]))
        }
    }
}
