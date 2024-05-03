//
//  CoreDataController.swift
//  fit3178_majorAssignment
//
//  Created by Chin Yen Tung on 1/5/2024.
//

import UIKit
import CoreData

class CoreDataController: NSObject, DatabaseProtocol, NSFetchedResultsControllerDelegate {
    var listeners = MulticastDelegate<DatabaseListener>()
    var persistentContainer: NSPersistentContainer      // holds a reference to our persistent container
    var allApplicationsFetchedResultsController: NSFetchedResultsController<ApplicationDetails>?
    var allJournalEntryFetchedResultsController: NSFetchedResultsController<JournalEntry>?
    
    // fetchAllApplications method:
    // used to query Core Data to retrieve all application entities stored within persistent memory
    func fetchAllApplications() -> [ApplicationDetails] {
        let request: NSFetchRequest<ApplicationDetails> = ApplicationDetails.fetchRequest()       // create a fetch request.
        let nameSortDescriptor = NSSortDescriptor(key: "jobTitle", ascending: true) // specify a sort descriptor.
        request.sortDescriptors = [nameSortDescriptor]                          // this ensures that the results have an order.
        
        // Initialise Fetched Results Controller
        // need to provide: the fetch request, the managed object context we want to perform the fetch on
        allApplicationsFetchedResultsController = NSFetchedResultsController<ApplicationDetails>(
            fetchRequest: request, managedObjectContext: persistentContainer.viewContext,
            sectionNameKeyPath: nil, cacheName: nil
        )
        
        // Set this class to be the results delegate
        allApplicationsFetchedResultsController?.delegate = self      // the database controller is set to be its delegate
        
        // perform the fetch request (which will begin the listening process)
        do {
            try allApplicationsFetchedResultsController?.performFetch()
        } catch {
            print("Fetch Request Failed: \(error)")
        }
        
        if allApplicationsFetchedResultsController == nil {   // check if the fetched results controller is nil (ie. not instantiated)
        // Do something
        }
        //check if it contains fetched objects
        if let applications = allApplicationsFetchedResultsController?.fetchedObjects {
            return applications   // If it does, return the array
        }
        return [ApplicationDetails]()
    }
    
    func fetchAllJournalEntries() -> [JournalEntry] {
        let request: NSFetchRequest<JournalEntry> = JournalEntry.fetchRequest()       // create a fetch request.
        let nameSortDescriptor = NSSortDescriptor(key: "journalEntryTitle", ascending: true) // specify a sort descriptor.
        request.sortDescriptors = [nameSortDescriptor]                          // this ensures that the results have an order.
        
        // Initialise Fetched Results Controller
        // need to provide: the fetch request, the managed object context we want to perform the fetch on
        allJournalEntryFetchedResultsController = NSFetchedResultsController<JournalEntry>(
            fetchRequest: request, managedObjectContext: persistentContainer.viewContext,
            sectionNameKeyPath: nil, cacheName: nil
        )
        
        // Set this class to be the results delegate
        allJournalEntryFetchedResultsController?.delegate = self      // the database controller is set to be its delegate
        
        // perform the fetch request (which will begin the listening process)
        do {
            try allJournalEntryFetchedResultsController?.performFetch()
        } catch {
            print("Fetch Request Failed: \(error)")
        }
        
        if allJournalEntryFetchedResultsController == nil {   // check if the fetched results controller is nil (ie. not instantiated)
        // Do something
        }
        //check if it contains fetched objects
        if let entry = allJournalEntryFetchedResultsController?.fetchedObjects {
            return entry   // If it does, return the array
        }
        return [JournalEntry]()
    }
    
    override init() {
        // instantiate the Core Data stack
        // initializes the Persistent Container property using the data model named "App-Datamodel".
        persistentContainer = NSPersistentContainer(name: "App-DataModel")
        
        // loads the Core Data stack
        persistentContainer.loadPersistentStores() { (description, error ) in
            // provide a closure for error handling - trigger a fatal error if the stack fails to load
            if let error = error {
                fatalError("Failed to load Core Data Stack with error: \(error)")
            }
        }
        
        super.init()
        
        // attempt to fetch all the heroes from the database. If this returns an empty array:
        if fetchAllApplications().count == 0 {
            createDefaultApplications()
        }
        if fetchAllJournalEntries().count == 0 {
            createDefaultJournalEntries()
        }
    }
    
    // cleanup method: check to see if there are changes to be saved inside of the view context and then save, as necessary
    func cleanup() {
        if persistentContainer.viewContext.hasChanges {
            do {
                // Changes made to the managed object context must be explicitly saved by calling the save method on the managed object context
                // method can throw an error, so must be done within a do-catch statement.
                try persistentContainer.viewContext.save()
            } catch {
                fatalError("Failed to save changes to Core Data with error: \(error)")
            }
        }
    }
    
    // addApplication method: responsible for adding new applications to Core Data.
    func addApplication(jobTitle: String, company: String, jobLocation: String, jobMode: JobMode, salary: Double, postURL: String, applicationStatus: ApplicationStatus, notes: String) -> ApplicationDetails {
        let application = NSEntityDescription.insertNewObject(forEntityName: "ApplicationDetails", into: persistentContainer.viewContext) as! ApplicationDetails
    
        application.jobTitle = jobTitle
        application.company = company
        application.jobLocation = jobLocation
        application.applicationJobMode = jobMode
        application.salary = salary
        application.postURL = postURL
        application.applicationApplicationStatus = applicationStatus
        application.notes = notes
        
        return application
    }
    
    // deleteApplication method:
    // takes in an application to be deleted and removes it from the main managed object context
    // deletion will not be made permanent until the managed context is saved
    func deleteApplication(applicationDetails: ApplicationDetails) {
        persistentContainer.viewContext.delete(applicationDetails)
    }
    
    func addJournalEntry(entryTitle: String, entryDate: String, entryCategories: String, entryDes: String) -> JournalEntry {
        let entry = NSEntityDescription.insertNewObject(forEntityName: "JournalEntry", into: persistentContainer.viewContext) as! JournalEntry
        
        entry.journalEntryTitle = entryTitle
        entry.journalEntryDate = entryDate
        entry.journalEntryCategory = entryCategories
        entry.journalEntryDesc = entryDes
        
        return entry
    }
    
    func deleteJournalEntry(journalEntry: JournalEntry) {
        persistentContainer.viewContext.delete(journalEntry)
    }
    
    // addListener method:
    func addListener(listener: DatabaseListener) {
        // adds the new database listener to the list of listeners.
        listeners.addDelegate(listener)
        
        // provide the listener with initial immediate results depending on what type of listener it is
        // first, check the listener type
        // if the type = heroes or all, call the delegate method onAllHeroesChange
        if listener.listenerType == .applicationDetails {
            // pass through all applications fetched from the database.
            listener.onAllApplicationDetailsChange(change: .update, applicationDetails: fetchAllApplications())
        } else if listener.listenerType == .journalEntry {
            // pass through all journal entries fetched from the database.
            listener.onAllJournalEntryChange(change: .update, journalEntry: fetchAllJournalEntries())
        }
    }
    
    // removeListener method: passes the specified listener to the multicast delegate class, then remove it from the set of saved listeners
    func removeListener(listener: DatabaseListener) {
        listeners.removeDelegate(listener)
    }
    
    func createDefaultApplications() {
        let _ = addApplication(jobTitle: "Software Developer", company: "Google", jobLocation: "Sydney", jobMode: .Hybrid,
                               salary: 25245, postURL: "www.google.com/job", applicationStatus: .Applied, notes: "big tech")
        let _ = addApplication(jobTitle: "Software Engineer", company: "Atlassian", jobLocation: "Melbourne", jobMode: .InPerson,
                               salary: 437347, postURL: "www.atlassian.com/job", applicationStatus: .Interview, notes: "big tech")
        let _ = addApplication(jobTitle: "Data Scientist", company: "SIG", jobLocation: "Sydney", jobMode: .Online,
                               salary: 7869, postURL: "www.sig.com/job", applicationStatus: .OA, notes: "quant")
        let _ = addApplication(jobTitle: "Data Engineer", company: "KPMG", jobLocation: "Melbourne", jobMode: .Hybrid,
                               salary: 262785, postURL: "www.kpmg.com/job", applicationStatus: .Offered, notes: "consulting")
        let _ = addApplication(jobTitle: "Web Developer", company: "Google", jobLocation: "Sydney", jobMode: .InPerson,
                               salary: 999999, postURL: "www.google.com/job", applicationStatus: .OA, notes: "big tech")
        let _ = addApplication(jobTitle: "Software Engineer", company: "Optiver", jobLocation: "Melbourne", jobMode: .Online,
                               salary: 463799, postURL: "www.Optiver.com/job", applicationStatus: .Applied, notes: "quant")
        let _ = addApplication(jobTitle: "Data Scientist", company: "Quantium", jobLocation: "Sydney", jobMode: .Hybrid,
                               salary: 319577, postURL: "www.Quantium.com/job", applicationStatus: .Offered, notes: "ds consulting")
        let _ = addApplication(jobTitle: "Data Engineer", company: "Quantium", jobLocation: "Melbourne", jobMode: .Online,
                               salary: 994955, postURL: "www.Quantium.com/job", applicationStatus: .Interview, notes: "data consulting")
        cleanup()
    }
    
    func createDefaultJournalEntries() {
        let _ = addJournalEntry(entryTitle: "Old Folks Home Volunteer Day", entryDate: "20-May-2023", entryCategories: "Adaptability",
                                entryDes: "I went to volunteer at the old folks home and developed adaptability skills.")
        let _ = addJournalEntry(entryTitle: "Monash Clayton Open Day", entryDate: "12-May-2023", entryCategories: "Adaptability",
                                entryDes: "I went to volunteer at Monash Clayton Open Day and developed adaptability skills.")
        let _ = addJournalEntry(entryTitle: "Monash Volunteer Day", entryDate: "13-May-2023", entryCategories: "Communication",
                                entryDes: "I went to volunteer at Monash Volunteer Day and developed communication and leadership skills.")
        let _ = addJournalEntry(entryTitle: "Monash Caulfield Open Day", entryDate: "12-May-2023", entryCategories: "Communication",
                                entryDes: "I went to volunteer at the old folks home and developed Communication skills.")
        let _ = addJournalEntry(entryTitle: "RMIT Volunteer Day", entryDate: "14-May-2023", entryCategories: "Leadership",
                                entryDes: "I went to volunteer at RMIT Volunteer Day and developed Leaderhsip skills.")
        let _ = addJournalEntry(entryTitle: "Ambassador", entryDate: "17-Apr-2023", entryCategories: "Leadership",
                                entryDes: "I went to volunteer to be an Ambassador and developed Leadership skills.")
        cleanup()
    }
    
    // MARK: - Fetched Results Controller Protocol methods
    
    // This will be called whenever the FetchedResultsController detects a change to the result of its fetch.
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        // 1. check if the controller is allHeroesFetchedResultsController
        if controller == allApplicationsFetchedResultsController {
            // 2. if it is, call the MulticastDelegate’s invoke method
            listeners.invoke() { listener in
                // 3. checks if it is listening for changes to application details
                if listener.listenerType == .applicationDetails {
                    // 4. call the onAllApplicationDetailsChange method, passing it the updated list of heroes
                    listener.onAllApplicationDetailsChange(change: .update, applicationDetails: fetchAllApplications())
                }
            }
        } else if controller == allJournalEntryFetchedResultsController {
            listeners.invoke() { listener in
                if listener.listenerType == .journalEntry {
                    listener.onAllJournalEntryChange(change: .update, journalEntry: fetchAllJournalEntries())
                }
            }
        }
    }
}
