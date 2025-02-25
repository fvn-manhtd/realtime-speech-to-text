/*
 See LICENSE folder for this sample's licensing information.
 */

import SwiftUI

struct NewScrumSheet: View {
    @State private var newScrum = DailyScrum.emptyScrum
    @Binding var scrums: [DailyScrum]
    @Binding var isPresentingNewScrumView: Bool
    @State private var isShowingAlert = false  // State variable to manage alert presentation
    
    var body: some View {
        NavigationStack {
            DetailEditView(scrum: $newScrum)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button(String(localized: "Dismiss")) {
                            isPresentingNewScrumView = false
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button(String(localized: "Add")) {
                            if newScrum.attendees.isEmpty {
                                isShowingAlert = true  // Show alert if no attendees
                            } else {
                                scrums.append(newScrum)
                                isPresentingNewScrumView = false
                            }
                        }
                        .alert(isPresented: $isShowingAlert) {
                            Alert(
                                title: Text(String(localized: "No_Attendees")),
                                message: Text(String(localized: "Please_add_at_least_one_attendee")),
                                dismissButton: .default(Text("OK"))
                            )
                        }
                    }
                }
        }
    }
}

struct NewScrumSheet_Previews: PreviewProvider {
    static var previews: some View {
        NewScrumSheet(scrums: .constant(DailyScrum.sampleData), isPresentingNewScrumView: .constant(true))
    }
}
