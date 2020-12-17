//
//  ContentView.swift
//  Cut Counter
//
//  Created by Franco Velasco on 10/7/20.
//

import SwiftUI
import CoreData

struct ContentView: View {
    //inherits the colorscheme of the device from the environment
    @Environment(\.colorScheme) var colorScheme
    
    //get subjects
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(entity: ClassEntry.entity(), sortDescriptors: []) var listOfSubjects: FetchedResults<ClassEntry>
    
    //control the modal that lets the user add a subject
    @State var showAddSubjectView = false
    
    //control the modal that makes the intro screen show (by default, a nil bool from UserDefaults evaluates to False)
    @State var showIntroScreenView = !defaults.bool(forKey: "showIntroScreen")
    
    //string / subject to search
    @State var subjectToSearch = ""
    
    //check if user wants to add a grading period
    @State var addGradingPeriod = false
    
    //variables to set a grading period
    @State var gradingPeriodName = ""
    @State var schoolYear = ""
    
    //Binding means that the struct doesn't own the data, but can manipulate it
    @Binding var recentlyArchivedOrDeletedEntry: Bool
    
    var body: some View {
        NavigationView {
            ZStack {
                //set a background
                if colorScheme == .light {
                    Color.bgColor
                        .edgesIgnoringSafeArea(.all)
                } else {
                    Color.black
                        .edgesIgnoringSafeArea(.all)
                }
                
                VStack {
                    //geom reader gets its data from the size of the current parent container it's in (hence geom reader -- reading the geometry)
                    GeometryReader { g in
                        VStack {
                            VStack {
                                ZStack {
                                    Color.blue
                                        .edgesIgnoringSafeArea(.all)
                                        .opacity(0.85)
                                    VStack {
                                        Spacer()
                                        HStack {
                                            //check if a grading period exists in storage, if not, prompt user to make one
                                            if let semester = defaults.string(forKey: "currentGradingPeriod") {
                                                VStack (alignment: .leading) {
                                                    Text(semester)
                                                        .fontWeight(.semibold)
                                                    Text(defaults.string(forKey: "schoolYear") ?? "")
                                                }
                                                .font(.title)
                                                Spacer()
                                            } else if addGradingPeriod == false {
                                                Button(action: {
                                                    self.addGradingPeriod = true
                                                }) {
                                                    Text("Set Grading Period")
                                                        .font(.title3)
                                                        .fontWeight(.semibold)
                                                        .padding(3)
                                                        .background(Color.white)
                                                        .cornerRadius(7.5)
                                                    Spacer()
                                                }
                                                Spacer()
                                            } else if addGradingPeriod == true { //add a grading period
                                                HStack {
                                                    VStack {
                                                        TextField("Grading Period", text: self.$gradingPeriodName)
                                                        Divider()
                                                            .frame(height: 1)
                                                            .background(Color.white)
                                                        TextField("School Year", text: self.$schoolYear)
                                                    }
                                                    .padding(6)
                                                    .cornerRadius(7.5)
                                                    .overlay(RoundedRectangle(cornerRadius: 7.5).stroke(Color.white, lineWidth: 1)) //create a rounded border
                                                    Spacer()
                                                    VStack {
                                                        Spacer()
                                                        Button(action: {
                                                            defaults.set(gradingPeriodName, forKey: "currentGradingPeriod")
                                                            defaults.set(schoolYear, forKey: "schoolYear")
                                                            self.addGradingPeriod = false
                                                        }) {
                                                            Text("Set")
                                                                .fontWeight(.medium)
                                                        }
                                                        .padding(6)
                                                        .background(Color.white)
                                                        .foregroundColor(.blue)
                                                        .cornerRadius(7.5)
                                                        .disabled(gradingPeriodName == "" && schoolYear == "")
                                                    }
                                                }
                                            }
                                        }
                                        .padding(10)
                                    }
                                }
                            }
                            .frame(height: g.size.height / 6)
                            
                            VStack(alignment: .center) {
                                //check if there are actual subjects to be shown, and if the subjects have been deleted/archived (so that deleted subjects don't get shown
                                if listOfSubjects.count > 0 && !self.recentlyArchivedOrDeletedEntry {
                                    HStack {
                                        Image(systemName: "magnifyingglass")
                                        TextField("Search Subject", text: self.$subjectToSearch)
                                        if subjectToSearch != "" {
                                            Button(action: {
                                                self.subjectToSearch = ""
                                            }) {
                                                Image(systemName: "xmark.circle.fill")
                                            }
                                        }
                                    }
                                    .padding(3)
                                    .cornerRadius(7.5)
                                    .padding(6)
                                    
                                    //show indicators are the scroll bars
                                    ScrollView(.vertical, showsIndicators: false) {
                                        ForEach(listOfSubjects, id: \.self) { subject in
                                            //check if it matches the search condition
                                            if subjectToSearch == "" || (subjectToSearch != "" && subject.nameOfClass!.contains(subjectToSearch)) {
                                                classViewContainer(inheritedData: subject)
                                                //parse the nsmanagedobject (the data from the core data) into an object that can be easily read
                                            }
                                        }
                                    }
                                } else {
                                    Spacer()
                                    HStack {
                                        Spacer()
                                        Text("No Subjects Entered Yet")
                                        Spacer()
                                    }
                                    Spacer()
                                }
                            }
                        }
                    }
                }
                //.sheet is the modal
                .sheet(isPresented: self.$showAddSubjectView) {
                    addSubject(showAddSubjectView: self.$showAddSubjectView, recentlyArchivedOrDeletedEntry: self.$recentlyArchivedOrDeletedEntry)
                }
                
                VStack {
                    Spacer()
                    HStack {
                        Button(action: {
                            self.showAddSubjectView = true
                        }) {
                            HStack {
                                Image(systemName: "plus")
                                Text("Add Subject")
                                    .fontWeight(.medium)
                            }
                            .padding(6)
                            .background(Color.blue)
                            .foregroundColor(Color.white)
                            .cornerRadius(7.5)
                            .opacity(0.85)
                        }
                        .padding(.bottom, 10)
                    }
                }
            }
            .navigationBarItems(leading: Text("Cut Counter").font(.title).fontWeight(.bold).foregroundColor(.white))
        }
        .sheet(isPresented: self.$showIntroScreenView) {
            introScreen(showIntroScreen: self.$showIntroScreenView)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(recentlyArchivedOrDeletedEntry: .constant(true)).environment(\.colorScheme, .dark)
        //classViewContainer()
    }
}

//This is the view container for the subjects that will be shown on the main interface
struct classViewContainer: View {
    //a question mark indicates an optional -- the value could be nil
    var inheritedData: ClassEntry? = nil
    @State var changeInCuts: Int = 0
    var currentTotalNumberOfCuts: Int {
        //if the string currentNumOfCuts can be parsed into an int
        if var currentNumOfCuts = Int(inheritedData?.currentNumOfCuts ?? "") {
            currentNumOfCuts += changeInCuts
            changeInCuts = 0
            return currentNumOfCuts
        }
        return 0
    }
    
    var colorOfView: (bg: Color, text: Color) { //creating a tuple to control the view and text color
        let maxCuts = Double(inheritedData?.maxNumOfCuts ?? "1.0")!
        let currentCuts = Double(inheritedData?.currentNumOfCuts ?? "0.0")!
        let quotient = currentCuts / maxCuts
        switch quotient {
            case 0.75...1:
                return (Color.red, Color.white)
            case 0.5..<0.75:
                return (Color.orange, Color.white)
            case 0.25..<0.5:
                return (Color.yellow, Color.black)
            case 0..<0.25:
                fallthrough //go to the next case
            default:
                return (Color.green, Color.black)
        }
    }

    var body: some View {
         HStack {
             VStack(alignment: .leading) {
                Text(inheritedData?.nameOfClass ?? "Name")
                     .font(.title3)
                     .fontWeight(.medium)
                Text("\(inheritedData?.daysOfClass ?? "Days"), \(inheritedData?.timeOfClass ?? "Time")")
                     .fontWeight(.light)
             }
             .foregroundColor(colorOfView.text)
             Spacer()
             HStack {
                 Button(action: { //decrease the number of cuts by one
                    changeInCuts -= 1
                    changeNoOfCuts(inheritedData?.nameOfClass, toNum: currentTotalNumberOfCuts)
                    refreshEntries()
                 }) {
                     Image(systemName: "minus.circle.fill")
                         .font(.title2)
                 }
                 .disabled(inheritedData?.currentNumOfCuts == "0")
                 VStack(spacing: 0) {
                    Text("\(currentTotalNumberOfCuts)")
                         .font(.title)
                         .fontWeight(.medium)
                    Text("out of \(inheritedData?.maxNumOfCuts ?? "6")")
                         .font(.footnote)
                 }
                 .foregroundColor(colorOfView.text)
                 .padding(.horizontal, 3)
                 Button(action: { //increase the number of cuts
                    changeInCuts += 1
                    changeNoOfCuts(inheritedData?.nameOfClass, toNum: currentTotalNumberOfCuts)
                    refreshEntries()
                 }) {
                     Image(systemName: "plus.circle.fill")
                         .font(.title2)
                 }
                 .disabled(inheritedData?.currentNumOfCuts == inheritedData?.maxNumOfCuts)
             }
         }
         .padding(6)
         .background(colorOfView.bg)
         .cornerRadius(7.5)
         .padding(.horizontal, 6)
    }
}
