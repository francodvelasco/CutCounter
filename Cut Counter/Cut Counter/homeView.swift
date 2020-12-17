//
//  homeView.swift
//  Cut Counter
//
//  Created by Franco Velasco on 10/12/20.

import SwiftUI

//this essentially makes all of it into a tab-based app
struct homeView: View {
    //because of how structs deal with data, deleting the entries doesn't really remove them from the view
    //this one is designed to deal with that
    @State var recentlyArchivedOrDeletedEntry = false
    
    var body: some View {
        TabView {
            ContentView(recentlyArchivedOrDeletedEntry: self.$recentlyArchivedOrDeletedEntry)
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }
            
            archivedSubjectsView()
                .tabItem {
                    Image(systemName: "archivebox")
                    Text("Archive")
                }
            
            settingsView(recentlyArchivedOrDeletedEntry: self.$recentlyArchivedOrDeletedEntry)
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
        }
    }
}

struct homeView_Previews: PreviewProvider {
    static var previews: some View {
        homeView()
    }
}
