//
//  archivedSubjectsView.swift
//  Cut Counter
//
//  Created by Franco Velasco on 10/10/20.
//

import SwiftUI

struct archivedSubjectsView: View {
    //inherits the colorscheme of the device from the environment
    @Environment(\.colorScheme) var colorScheme
    
    //get the archived entries
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(entity: ArchivedClassEntry.entity(), sortDescriptors: []) var listInArchive: FetchedResults<ArchivedClassEntry>
    
    //string / subject to search
    @State var subjectToSearch = ""
    
    //filter string condition
    @State var filterBy = ""
    
    //bring up the action sheet
    @State var showFilterActionSheet = false
    
    var archivedSubjectDates: [String] {
        var dates: [String] = []
        
        for entry in listInArchive {
            let gradePeriod = "\(entry.currentGradingPeriod ?? "") \(entry.schoolYear ?? "")"
            
            if !dates.contains(gradePeriod) {
                dates.append(gradePeriod)
            }
        }
        
        return dates
    }
    
    //create the button for the action sheet that will let the user filter the subjects by grading period and date
    var actionSheetButtons: [ActionSheet.Button] {
        var output: [ActionSheet.Button] = []
        
        for date in archivedSubjectDates {
            output.append(ActionSheet.Button.default(Text(date), action: {
                self.filterBy = date
                self.showFilterActionSheet = false
            }))
        }
        
        //create the button that allows the user to view all
        output.append(.default(Text("View All"), action: {
            self.filterBy = ""
            self.showFilterActionSheet = false
        }))
        
        output.append(.cancel())
        
        return output
    }
    
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
                    GeometryReader { g in
                        VStack {
                            VStack {
                                ZStack {
                                    Color.yellow
                                        .edgesIgnoringSafeArea(.all)
                                        .opacity(0.85)
                                    VStack {
                                        Spacer()
                                        HStack {
                                            VStack(alignment: .leading) {
                                                Text("Archive")
                                                    .font(.largeTitle)
                                                    .fontWeight(.bold)
                                                    .foregroundColor(.black)
                                                if filterBy != "" {
                                                    VStack (alignment: .leading) {
                                                        Text(filterBy)
                                                            .fontWeight(.medium)
                                                    }
                                                    .font(.title3)
                                                }
                                            }
                                            .padding(10)
                                            Spacer()
                                        }
                                    }
                                }
                            }
                            .frame(height: g.size.height / 6)
                            
                            VStack(alignment: .center) {
                                if listInArchive.count > 0 {
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
                                        Button(action: {
                                            self.showFilterActionSheet = true
                                        }) {
                                            Text("Filter")
                                                .padding(3)
                                                .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                                                .background(Color.white)
                                                .cornerRadius(7.5)
                                        }
                                    }
                                    .padding(3)
                                    .cornerRadius(7.5)
                                    .padding(6)
                                    
                                    ScrollView(.vertical, showsIndicators: false) {
                                        ForEach(listInArchive, id: \.self) { subject in
                                            //check if it matches the search condition
                                            if subjectToSearch == "" || (subjectToSearch != "" && subject.nameOfClass!.contains(subjectToSearch)) {
                                                //check if it matches filter condition
                                                if filterBy == "" || (filterBy != "" && filterBy == "\(subject.currentGradingPeriod ?? "") \(subject.schoolYear ?? "")") {
                                                    archiveViewContainer(inheritedData: subject)
                                                }
                                            }
                                        }
                                    }
                                } else {
                                    HStack {
                                        Spacer()
                                        Text("No Subjects in Archive")
                                        Spacer()
                                    }
                                }
                            }
                        }
                    }
                }
                .actionSheet(isPresented: self.$showFilterActionSheet) {
                    ActionSheet(title: Text("Choose Filter"), message: Text("Choose grading period and school year to filter the archive by."), buttons: actionSheetButtons)
                }
            }
            .navigationTitle("")
            .navigationBarItems(leading: Text("Cut Counter").font(.title).fontWeight(.bold).foregroundColor(.black))
        }
    }
}

struct archivedSubjectsView_Previews: PreviewProvider {
    static var previews: some View {
        archivedSubjectsView()//.environment(\.colorScheme, .dark)
    }
}

//This is the view container for the archived subjects that will be shown on the main interface
//It's pretty much patterned after the one in the main view, except for the removal of buttons to change the number of cuts
struct archiveViewContainer: View {
    var inheritedData: ArchivedClassEntry? = nil
    
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
             Spacer()
             HStack {
                 VStack(spacing: 0) {
                    Text("\(inheritedData?.currentNumOfCuts ?? "4")")
                         .font(.title)
                    Text("out of \(inheritedData?.maxNumOfCuts ?? "6")")
                         .font(.footnote)
                 }
                 .padding(.horizontal, 3)
             }
         }
         .padding(6)
         .background(colorOfView.bg)
         .foregroundColor(colorOfView.text)
         .cornerRadius(7.5)
         .padding(.horizontal, 6)
    }
}
