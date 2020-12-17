//
//  settingsView.swift
//  Cut Counter
//
//  Created by Franco Velasco on 10/10/20.
//

import SwiftUI

struct settingsView: View {
    //similar to what's in the conent view -- to manipulate showing the variables
    @Binding var recentlyArchivedOrDeletedEntry: Bool
    
    @State var showDeleteAlert = false
    @State var showArchiveAlert = false
    
    var body: some View {
        Form {
            Section(header: Text("About the App")) {
                HStack {
                    Spacer()
                    Image("CCLogo58")
                        .cornerRadius(15)
                    VStack(alignment: .leading) {
                        Text("Cut Counter")
                            .fontWeight(.semibold)
                            .font(.title3)
                        Group {
                            Text("by Franco Velasco")
                            Text("for DSC-L Application Purposes")
                        }
                        .font(.footnote)
                    }
                    Spacer()
                }
                .padding(3)
            }
            
            Section(header: Text("Reset Period"), footer: Text("This will also delete all the subjects for the current grading period, \(defaults.string(forKey: "currentGradingPeriod") ?? "which hasn't been") \(defaults.string(forKey: "schoolYear") ?? "set yet").") + Text(" This does not archive your subject cuts.").fontWeight(.semibold)) {
                Button(action: {
                    self.showDeleteAlert = true //trigger delete alert
                }) {
                    HStack {
                        Spacer()
                        Text("Reset Grading Period")
                            .fontWeight(.medium)
                        Spacer()
                    }
                    .foregroundColor(.white)
                }
                .listRowBackground(Color.blue)
                .disabled(subjectEntries.count == 0)
                .alert(isPresented: self.$showDeleteAlert) { //alert to reset grading period (ie. delete subjects and reset grading period default
                    Alert(title: Text("Are you sure you want to reset the current grading period?"), message: Text("This will not archive your subjects. Once your subjects are deleted and grading period is reset, they will be gone forever (a long time!)"), primaryButton: .destructive(Text("Yes"), action: {
                        defaults.setValue(nil, forKey: "currentGradingPeriod")
                        defaults.setValue(nil, forKey: "schoolYear")
                        removeAllSubjects()
                        recentlyArchivedOrDeletedEntry = true
                    }), secondaryButton: .cancel(Text("No")))
                }
            }
            
            Section(header: Text("Reset and Archive")) {
                Button(action: {
                    self.showArchiveAlert = true
                }) {
                    HStack {
                        Spacer()
                        Text("Archive Grading Period")
                            .fontWeight(.medium)
                        Spacer()
                    }
                    .foregroundColor(.white)
                }
                .listRowBackground(Color.blue)
                .disabled(subjectEntries.count == 0)
            }
            
            Section(header: Text("About the developer")) {
                Link(destination: URL(string: "https://francodvelasco.github.io")!) {
                    HStack {
                        Text("See my website!")
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                }
                
                Link(destination: URL(string: "https://www.twitter.com/francodvelasco")!) {
                    HStack {
                        Text("Check out my Twitter!")
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                }
                
                Link(destination: URL(string: "https://github.com/francodvelasco")!) {
                    HStack {
                        Text("Check out my Github!")
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                }
            }
        }
        .alert(isPresented: self.$showArchiveAlert) { //alert when archiving the grading period
            Alert(title: Text("Are you sure you want to archive the current grading period?"), message: Text("All the subjects in the current grading period will be transferred over to the archive."), primaryButton: .destructive(Text("Yes"), action: {
                archiveSubjects()
                defaults.setValue(nil, forKey: "currentGradingPeriod")
                defaults.setValue(nil, forKey: "schoolYear")
                removeAllSubjects()
                recentlyArchivedOrDeletedEntry = true
            }), secondaryButton: .cancel(Text("No")))
        }
        
    }
}

struct settingsView_Previews: PreviewProvider {
    static var previews: some View {
        settingsView(recentlyArchivedOrDeletedEntry: .constant(true))
    }
}
