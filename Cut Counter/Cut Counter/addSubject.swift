//
//  addSubject.swift
//  Cut Counter
//
//  Created by Franco Velasco on 10/7/20.
//

import SwiftUI

struct addSubject: View {
    //inherit calendar from the environment -- makes the class times work
    @Environment(\.calendar) var calendar
    
    //declare variables that will be added as an entry to ClassEntry -- aka adding a subject to track
    @State var nameOfClass: String = ""
    @State var maxNumOfCuts: Int = 1
    
    //store selected dates of class into a list, that will be converted into a string later
    @State var listOfDatesOfClass: [String] = []
    
    //the declarations below will allow the user to select a range of dates
    @State var startTimeOfClass = Date()
    @State var endTimeOfClass = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
    
    //Binding means the struct doesn't own the data, but could manipulate it
    @Binding var showAddSubjectView: Bool
    @Binding var recentlyArchivedOrDeletedEntry: Bool
    
    //These declarations work for error handling -- if there's no subject name / dates / class time doesn't work, then it'll throw an error
    @State var showAlert = false
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    Form {
                        Section(header: Text("Subject Name")) {
                            TextField("Name of Subject", text: self.$nameOfClass)
                        }
                        
                        Section(header: Text("Class Days")) {
                            ForEach(daysOfTheWeek.allCases, id: \.self) { day in
                                Button(action: {
                                    if !listOfDatesOfClass.contains(day.rawValue) {
                                        listOfDatesOfClass.append(day.rawValue)
                                        //add the day to the list if the user hasn't selected it
                                    } else {
                                        listOfDatesOfClass.remove(at: listOfDatesOfClass.firstIndex(of: day.rawValue)!)
                                        //remove the day from the list if the user deselects it
                                    }
                                }) {
                                    HStack {
                                        Text(day.rawValue)
                                        Spacer()
                                        if listOfDatesOfClass.contains(day.rawValue) {
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                            }
                        }
                        
                        Section(header: Text("Class Time")) {
                            HStack {
                                Text("Time")
                                Spacer()
                                Text("\(formatTime(startTimeOfClass)) - \(formatTime(endTimeOfClass))")
                                if self.endTimeOfClass < self.startTimeOfClass {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundColor(.yellow)
                                }
                            }
                            
                            DatePicker("Start Time", selection: self.$startTimeOfClass, displayedComponents: [.hourAndMinute])
                            DatePicker("End Time", selection: self.$endTimeOfClass, displayedComponents: [.hourAndMinute])
                        }
                        
                        Section(header: Text("Max number of cuts")) {
                            Stepper("\(maxNumOfCuts) cut\(maxNumOfCuts > 1 ? "s" : "")", value: self.$maxNumOfCuts, in: 1...50, step: 1)
                        }
                        
                        Section {
                            Button(action: {
                                if listOfDatesOfClass.count == 0 || self.nameOfClass == "" || self.endTimeOfClass < self.startTimeOfClass {
                                    //if no dates are selected || name of class is empty || the end time of the class is earlier than the start time
                                    self.showAlert = true
                                } else {
                                    let timeOfClass = "\(formatTime(startTimeOfClass)) - \(formatTime(endTimeOfClass))"
                                    let daysOfClass = convertDatesToShortForm(listOfDatesOfClass)
                                    addNewClass(daysOfClass: daysOfClass, maxNoOfCuts: String(maxNumOfCuts), nameOfClass: nameOfClass, timeOfClass: timeOfClass)
                                    refreshEntries()
                                    self.showAddSubjectView = false
                                    recentlyArchivedOrDeletedEntry = false
                                }
                            }) {
                                HStack {
                                    Spacer()
                                    Text("Add Subject")
                                        .font(.headline)
                                    Spacer()
                                }
                                .foregroundColor(Color.white)
                            }
                            .listRowBackground(Color.blue)
                        }
                    }
                }
                .padding(.horizontal, 6)
            }
            .navigationBarTitle(Text("Add Subject"), displayMode: .inline)
            .navigationBarItems(trailing: Button(action: {
                self.showAddSubjectView = false
            }) {
                Text("Cancel")
            })
            .alert(isPresented: self.$showAlert) {
                Alert(title: Text("Something is wrong here..."), message: Text("Check if you filled up all of the information correctly!"), dismissButton: .default(Text("Got it!")))
            }
        }
    }
    
    //function to format the time into a readable class time
    func formatTime(_ date: Date) -> String {
        let formatting = DateFormatter()
        formatting.dateFormat = "h:mma"
        
        return formatting.string(from: date)
    }
    
    //get the selected list of days and convert them to the shorthand notation (ie. Mon, Wed, Fri to MWF)
    func convertDatesToShortForm(_ listOfDates: [String]) -> String {
        var output = ""
        
        for day in daysOfTheWeek.allCases {
            if listOfDatesOfClass.contains(day.rawValue) {
                output += String(day.rawValue.first!) + (day == .Thursday ? "h" : "")
                //swift doesn't have a convenient way of getting the first letter of a string with string[0], so here's a workaround
                //add an h if the day is thursday as well
            }
        }
        
        return output
    }
}

enum daysOfTheWeek: String, CaseIterable {
    case Monday, Tuesday, Wednesday, Thursday, Friday, Saturday
}

struct addSubject_Previews: PreviewProvider {
    static var previews: some View {
        addSubject(showAddSubjectView: .constant(true), recentlyArchivedOrDeletedEntry: .constant(true)).environment(\.colorScheme, .dark)
    }
}

