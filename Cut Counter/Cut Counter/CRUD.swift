//
//  CRUD.swift
//  Cut Counter
//
//  Created by Franco Velasco on 10/7/20.
//

import Foundation
import CoreData
import SwiftUI
import UIKit


/*
 Storage in iOS in handled through CoreData. This file contains the code necessary to interact with the data.
 This includes: Creating Data, Reading Data, Updating the Data and Deleting any Entry (Hence CRUD)
 */

    
func readEntries(fromEntity entity: String = "ClassEntry") -> [NSManagedObject] {
    var output: [NSManagedObject] = []
    
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
        return [] //if it can't find the delegate of the app, it exits the function
    }
    
    let managedContext = appDelegate.persistentContainer.viewContext //essentially this line with the line above try to access the CoreData stack
    
    let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entity)
    //get all the data from CoreData under ClassEntry
    do {
        
        try output = managedContext.fetch(fetchRequest)
    } catch let error as NSError {
        print("error caught: \(error)")
    }
    
    return output
}

//the function below adds a new subject that will be displayed in the main interface
func addNewClass(daysOfClass: String? = nil, maxNoOfCuts: String? = nil, nameOfClass: String? = nil, timeOfClass: String? = nil) {
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
        return
    }
    
    let managedContext = appDelegate.persistentContainer.viewContext
    
    let entity = NSEntityDescription.entity(forEntityName: "ClassEntry", in: managedContext)! //find the entity in the CoreData stack named "ClassEntry"
    
    let newEntry = NSManagedObject(entity: entity, insertInto: managedContext) //generate a new entry format that will be saved into ClassEntry
    
    //i'm using string to store numbers in the CoreData stack sas it's easier to handle than numbers
    newEntry.setValue("0", forKey: "currentNumOfCuts")
    newEntry.setValue(daysOfClass, forKey: "daysOfClass")
    newEntry.setValue(maxNoOfCuts, forKey: "maxNumOfCuts")
    newEntry.setValue(nameOfClass, forKey: "nameOfClass")
    newEntry.setValue(timeOfClass, forKey: "timeOfClass")
    
    //check if there's a set grading period and school year, if not, put an empty string in its place
    newEntry.setValue(defaults.string(forKey: "currentGradingPeriod") ?? "", forKey: "currentGradingPeriod")
    newEntry.setValue(defaults.string(forKey: "schoolYear") ?? "", forKey: "schoolYear")
    
    do {
        try managedContext.save() //save the new entry into the entity
    } catch let error as NSError {
        print("error caught: \(error), \(error.userInfo)")
    }
}

//function below lets the user add or subtract a cut
func changeNoOfCuts(_ nameOfClass: String? = nil, toNum: Int) {
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
        return 
    }
    
    let managedContext = appDelegate.persistentContainer.viewContext
    
    let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "ClassEntry")
    fetchRequest.predicate = NSPredicate(format: "nameOfClass == %@", nameOfClass ?? "" as CVarArg)
    //filter the subjects stored in ClassEntry to the subject cuts will be added to
    
    do {
        let subjectsToBeEdited = try managedContext.fetch(fetchRequest)
        
        let subjectToEdit = subjectsToBeEdited[0] as! NSManagedObject
        //managedContext.fetch brings a list of entries, just get the first one (since that's the one that matches with the subject whose cuts will change
        
        subjectToEdit.setValue("\(toNum)", forKey: "currentNumOfCuts")
        
        try managedContext.save()
        
    } catch let error as NSError {
        print("error caught: \(error), \(error.userInfo)")
    }
}

//function below deletes all the subjects stored in the current period
func removeAllSubjects() {
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
        return
    }
    
    let managedContext = appDelegate.persistentContainer.viewContext
    
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ClassEntry")
    let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
    
    do {
        try managedContext.execute(deleteRequest)
        try managedContext.save()
    } catch let error as NSError {
        print("Could not delete: \(error), \(error.userInfo)")
    }
}

func archiveSubjects() {
    let subjectsToArchive = readEntries()
    
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
        return
    }
    
    let managedContext = appDelegate.persistentContainer.viewContext
    
    let entity = NSEntityDescription.entity(forEntityName: "ArchivedClassEntry", in: managedContext)! //find the entity in the CoreData stack named "ClassEntry"
    
    for subject in subjectsToArchive {
        let newArchive = subject as! ClassEntry
        
        let newEntry = NSManagedObject(entity: entity, insertInto: managedContext)
        
        newEntry.setValue(newArchive.currentNumOfCuts, forKey: "currentNumOfCuts")
        newEntry.setValue(newArchive.daysOfClass, forKey: "daysOfClass")
        newEntry.setValue(newArchive.maxNumOfCuts, forKey: "maxNumOfCuts")
        newEntry.setValue(newArchive.nameOfClass, forKey: "nameOfClass")
        newEntry.setValue(newArchive.timeOfClass, forKey: "timeOfClass")
        
        newEntry.setValue(newArchive.currentGradingPeriod, forKey: "currentGradingPeriod")
        newEntry.setValue(newArchive.schoolYear, forKey: "schoolYear")
        
        do {
            try managedContext.save() //save the new entry into the entity
        } catch let error as NSError {
            print("error caught: \(error), \(error.userInfo)")
        }
    }

}
