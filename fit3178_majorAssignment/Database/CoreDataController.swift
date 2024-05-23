//
//  CoreDataController.swift
//  jobApplication_prepTrack_app
//
//  Created by Chin Yen Tung on 17/5/2024.
//

// TODO: figure out how firebase and coredata should work together
// - do we have separate controllers for them? or have them on the same controller swift file?
// - delete this file if we have them on the same controller file

import UIKit
import CoreData

class CoreDataController: NSObject, DatabaseProtocol, NSFetchedResultsControllerDelegate {
    var listeners = MulticastDelegate<DatabaseListener>()
    var persistentContainer: NSPersistentContainer      // holds a reference to our persistent container
    var allInterviewScheduleFetchedResultsController: NSFetchedResultsController<InterviewScheduleDetail>?
    
    // TODO: delete?
    var successfulSignUp: Bool = false
    
    // fetchAllApplications method:
    // used to query Core Data to retrieve all application entities stored within persistent memory
    func fetchAllInterview() -> [InterviewScheduleDetail] {
        let request: NSFetchRequest<InterviewScheduleDetail> = InterviewScheduleDetail.fetchRequest()       // create a fetch request.
        let nameSortDescriptor = NSSortDescriptor(key: "interviewTitle", ascending: true) // specify a sort descriptor.
        request.sortDescriptors = [nameSortDescriptor]                          // this ensures that the results have an order.
        
        // Initialise Fetched Results Controller
        // need to provide: the fetch request, the managed object context we want to perform the fetch on
        allInterviewScheduleFetchedResultsController = NSFetchedResultsController<InterviewScheduleDetail>(
            fetchRequest: request, managedObjectContext: persistentContainer.viewContext,
            sectionNameKeyPath: nil, cacheName: nil
        )
        
        // Set this class to be the results delegate
        allInterviewScheduleFetchedResultsController?.delegate = self      // the database controller is set to be its delegate
        
        // perform the fetch request (which will begin the listening process)
        do {
            try allInterviewScheduleFetchedResultsController?.performFetch()
        } catch {
            print("Fetch Request Failed: \(error)")
        }
        
        if allInterviewScheduleFetchedResultsController == nil {   // check if the fetched results controller is nil (ie. not instantiated)
        // Do something
        }
        //check if it contains fetched objects
        if let interviews = allInterviewScheduleFetchedResultsController?.fetchedObjects {
            return interviews   // If it does, return the array
        }
        return [InterviewScheduleDetail]()
    }
    
    override init() {
        // instantiate the Core Data stack
        // initializes the Persistent Container property using the data model named "App-Datamodel".
        persistentContainer = NSPersistentContainer(name: "InterviewScheduleDetail-Model")
        
        // loads the Core Data stack
        persistentContainer.loadPersistentStores() { (description, error ) in
            // provide a closure for error handling - trigger a fatal error if the stack fails to load
            if let error = error {
                fatalError("Failed to load Core Data Stack with error: \(error)")
            }
        }
        
        super.init()
        
        // attempt to fetch all the heroes from the database. If this returns an empty array:
        if fetchAllInterview().count == 0 {
            createDefaultInterviews()
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
    
    // addInterviewSchedule method: responsible for adding new interview schedules to Core Data.
    func addInterviewSchedule(interviewTitle: String, interviewStartDatetime: Date, interviewEndDatetime: Date, interviewVideoLink: String, interviewLocation: String, interviewNotifDatetime: Date, interviewNotes: String) -> InterviewScheduleDetail {
        let interview = NSEntityDescription.insertNewObject(forEntityName: "InterviewScheduleDetail", into: persistentContainer.viewContext) as! InterviewScheduleDetail
    
        interview.interviewTitle = interviewTitle
        interview.interviewStartDatetime = interviewStartDatetime
        interview.interviewEndDatetime = interviewEndDatetime
        interview.interviewVideoLink = interviewVideoLink
        interview.interviewLocation = interviewLocation
        interview.interviewNotifDatetime = interviewNotifDatetime
        interview.interviewNotes = interviewNotes
        
        return interview
    }
    
    // deleteInterviewSchedule method:
    // takes in an interview to be deleted and removes it from the main managed object context
    // deletion will not be made permanent until the managed context is saved
    func deleteInterviewSchedule(interviewScheduleDetail: InterviewScheduleDetail) {
        persistentContainer.viewContext.delete(interviewScheduleDetail)
    }
    
    func addApplication(jobTitle: String, company: String, jobLocation: String, jobMode: JobMode, salary: Double, postURL: String, applicationStatus: ApplicationStatus, notes: String) -> ApplicationDetail {
        let application = NSEntityDescription.insertNewObject(forEntityName: "ApplicationDetails", into: persistentContainer.viewContext) as! ApplicationDetail
            
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
    
    func deleteApplication(applicationDetails: ApplicationDetail) {
        // do nothing
    }
    
    func addJournalEntry(entryTitle: String, entryDate: String, entryCategories: [String], entryDes: String) -> JournalEntry {
        let entry = NSEntityDescription.insertNewObject(forEntityName: "JournalEntry", into: persistentContainer.viewContext) as! JournalEntry
                
        entry.entryTitle = entryTitle
        entry.entryDate = entryDate
        entry.entryCategories = entryCategories
        entry.entryDes = entryDes
        
        return entry
    }
    
    func deleteJournalEntry(journalEntry: JournalEntry) {
        // do nothing
    }
    
    func createUser(email: String, password: String, completion: @escaping () -> Void) {
        // do nothing
    }
    
    func loginUser(email: String, password: String, completion: @escaping () -> Void) {
        // do nothing
    }
    
    func signOutUser() {
        // do nothing
    }
    
    func setupApplicationListener() {
        // do nothing
    }
    
    func setupJournalEntryListener() {
        // do nothing
    }
    
    // addListener method:
    func addListener(listener: DatabaseListener) {
        // adds the new database listener to the list of listeners.
        listeners.addDelegate(listener)
        
        // provide the listener with initial immediate results depending on what type of listener it is
        // first, check the listener type
        // if the type = heroes or all, call the delegate method onAllHeroesChange
        if listener.listenerType == .interviewSchedule {
            // pass through all applications fetched from the database.
            listener.onAllInterviewScheduleChange(change: .update, interviewScheduleDetail: fetchAllInterview())
        }
    }
    
    // removeListener method: passes the specified listener to the multicast delegate class, then remove it from the set of saved listeners
    func removeListener(listener: DatabaseListener) {
        listeners.removeDelegate(listener)
    }
    
    func createDefaultInterviews() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyy"
        
        // create date objects from string
        let _ = addInterviewSchedule(interviewTitle: "Google Round 1 Interview", interviewStartDatetime: dateFormatter.date(from: "12-01-2024")!, interviewEndDatetime: dateFormatter.date(from: "13-01-2024")!, interviewVideoLink: "www.zoom.com", interviewLocation: "melbourne google office", interviewNotifDatetime: dateFormatter.date(from: "12-01-2024")!, interviewNotes: "good luck")
        let _ = addInterviewSchedule(interviewTitle: "SIG Round 3 Interview", interviewStartDatetime: dateFormatter.date(from: "15-01-2024")!, interviewEndDatetime: dateFormatter.date(from: "16-01-2024")!, interviewVideoLink: "", interviewLocation: "sydney SIG office", interviewNotifDatetime: dateFormatter.date(from: "15-01-2024")!, interviewNotes: "trade and tech")
        let _ = addInterviewSchedule(interviewTitle: "KPMG Round 1 Interview", interviewStartDatetime: dateFormatter.date(from: "17-01-2024")!, interviewEndDatetime: dateFormatter.date(from: "18-01-2024")!, interviewVideoLink: "www.zoom.com", interviewLocation: "", interviewNotifDatetime: dateFormatter.date(from: "17-01-2024")!, interviewNotes: "consulting data analytics")
        
        cleanup()
    }
    
    
    // MARK: - Fetched Results Controller Protocol methods
    
    // This will be called whenever the FetchedResultsController detects a change to the result of its fetch.
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        // 1. check if the controller is allInterviewScheduleFetchedResultsController
        if controller == allInterviewScheduleFetchedResultsController {
            // 2. if it is, call the MulticastDelegate’s invoke method
            listeners.invoke() { listener in
                // 3. checks if it is listening for changes to interview schedule details
                if listener.listenerType == .interviewSchedule {
                    // 4. call the onAllApplicationDetailsChange method, passing it the updated list of heroes
                    listener.onAllInterviewScheduleChange(change: .update, interviewScheduleDetail: fetchAllInterview())
                }
            }
        }
    }
}
