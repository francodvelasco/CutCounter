//
//  userDataModels.swift
//  Cut Counter
//
//  Created by Franco Velasco on 10/7/20.
//

import Foundation
import CoreData
import SwiftUI

//this essentially fetches the data from CoreData so that they're easily accessibly from memory
//not being in a struct also makes it easier to handle the data (as struct data is immutable)
var subjectEntries = readEntries()

func refreshEntries() {
    subjectEntries = readEntries()
}

//UserDefaults is another way of storing data -- think of it like one big dictionary
let defaults = UserDefaults.standard

func setDefaults() {
    if defaults.object(forKey: "showIntroScreen") == nil {
        defaults.set(true, forKey: "showIntroScreen")
        //check if showIntroScreen exists; if not, set it to true -- this will show the intro screen at the first boot-up
    }
}

//MARK: View Functions

//convert the RGB numbers to Color in SwiftUI
func RGBtoColor(_ r: Double, _ g: Double, _ b: Double) -> Color {
    return Color(red: r/255, green: g/255, blue: b/255, opacity: 1)
}

//extend the built-in Color definition to include new colors!
extension Color {
    static let bgColor = RGBtoColor(242, 242, 247)
}

