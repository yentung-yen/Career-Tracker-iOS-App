//
//  FirebaseController.swift
//  jobApplication_prepTrack_app
//
//  Created by Chin Yen Tung on 2/5/2024.
//

// TODO: figure out how firebase and coredata should work together
// - do we have separate controllers for them? or have them on the same controller swift file?
// - reformat this file if we have them on the same controller file so that it looks cleaner
//      - e.g. add MARK so that we can identify core data stuff more easily

import UIKit
import Firebase
import FirebaseFirestoreSwift
import CoreData

class FirebaseController: NSObject, DatabaseProtocol, NSFetchedResultsControllerDelegate {
    var authController: Auth
    var database: Firestore
    var applicationRef: CollectionReference?
    var journalEntryRef: CollectionReference?
    var currentUser: FirebaseAuth.User?
    var listeners = MulticastDelegate<DatabaseListener>()
    
    var applicationList: [ApplicationDetail]
    var journalEntryList: [JournalEntry]
    
    // CoreData stuff =======================================
    var persistentContainer: NSPersistentContainer      // holds a reference to our persistent container
    var allInterviewScheduleFetchedResultsController: NSFetchedResultsController<InterviewScheduleDetail>?
    
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
    // ======================================================
    
    override init(){
        // configure and initialize each of the Firebase frameworks we plan to use
        FirebaseApp.configure()
        authController = Auth.auth()
        database = Firestore.firestore()
        
        applicationList = [ApplicationDetail]()
        journalEntryList = [JournalEntry]()
        
        // CoreData stuff =======================================
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
        // ======================================================
        
        super.init()
        
        // CoreData stuff =======================================
        // attempt to fetch all the heroes from the database. If this returns an empty array:
        if fetchAllInterview().count == 0 {
            createDefaultInterviews()
        }
        // ======================================================
        
        // clear cache
//        database.clearPersistence { error in
//            if let error = error {
//                print("Error clearing Firestore cache: \(error)")
//            } else {
//                // Initialize listeners or perform other setup tasks after ensuring the cache is clear
//                self.setupApplicationListener()
//                self.setupJournalEntryListener()
//            }
//        }
        
        // in firebase, we need to be authenticated with Firebase to be able to read and/or write to the database
        // we need to ensure that we have signed on, before any attempts to access Firestore
        Task {
            do {
                // using anonymous authentication to sign on
                // do not need to provide any login credentials
                // Firebase will create an anonymous token for our device if we do not have one already
                let authDataResult = try await authController.signInAnonymously()
                
                // If no error, set currentUser to the fetched user  information
                currentUser = authDataResult.user
            }
            catch {
                // if there are any errors, use the fatalError method to stop application from running
                fatalError("Firebase Authentication Failed with Error\(String(describing:error))")
            }
            // call setupHeroListener method to begin setting up the database listeners.
            self.setupApplicationListener()
            self.setupJournalEntryListener()
        }
         
    }
    
    // CoreData stuff =======================================
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
    // ======================================================
    
    // addListener method:
    func addListener(listener: DatabaseListener) {
        // adds the new database listener to the list of listeners.
        listeners.addDelegate(listener)
        
        // provide the listener with initial immediate results depending on what type of listener it is
        // first, check the listener type
        // if the type = heroes or all, call the delegate method onAllHeroesChange
        if listener.listenerType == .applicationDetails {
            // pass through all applications fetched from the database.
            listener.onAllApplicationDetailsChange(change: .update, applicationDetails: applicationList)
        } else if listener.listenerType == .journalEntry {
            // pass through all journal entries fetched from the database.
            listener.onAllJournalEntryChange(change: .update, journalEntry: journalEntryList)
        } 
        // CoreData stuff =======================================
        else if listener.listenerType == .interviewSchedule {
            // pass through all applications fetched from the database.
            listener.onAllInterviewScheduleChange(change: .update, interviewScheduleDetail: fetchAllInterview())
        }
        // ======================================================
    }
    
    // removeListener method: passes the specified listener to the multicast delegate class, then remove it from the set of saved listeners
    func removeListener(listener: DatabaseListener) {
        listeners.removeDelegate(listener)
    }
    
    // addApplication method: responsible for adding new applications to Core Data.
    func addApplication(jobTitle: String, company: String, jobLocation: String, jobMode: JobMode, salary: Double, postURL: String, applicationStatus: ApplicationStatus, notes: String) -> ApplicationDetail {
        let application = ApplicationDetail()
    
        application.jobTitle = jobTitle
        application.company = company
        application.jobLocation = jobLocation
        application.jobMode = jobMode.rawValue
        application.salary = salary
        application.postURL = postURL
        application.applicationStatus = applicationStatus.rawValue
        application.notes = notes
        
        do {
            if let applicationRef = try applicationRef?.addDocument(from: application) {
                // Adding a document to Firestore returns a Database Reference to that specific object if successful.
                // use this reference to get the documentID - we use this to refer to documents in FIrestore
                application.id = applicationRef.documentID
            }
        } catch {
            print("Failed to add application")
        }
        
        return application
    }
    
    func deleteApplication(applicationDetails: ApplicationDetail){
        // check if they have a valid ID.
        // If they do, use it with the database references to delete them.
        if let applicationID = applicationDetails.id {
            applicationRef?.document(applicationID).delete()
        }
    }
    
    func addJournalEntry(entryTitle: String, entryDate: String, entryCategories: [String], entryDes: String) -> JournalEntry {
        let entry = JournalEntry()
        
        entry.entryTitle = entryTitle
        entry.entryDate = entryDate
        entry.entryCategories = entryCategories
        entry.entryDes = entryDes
        
        do {
            if let journalEntryRef = try journalEntryRef?.addDocument(from: entry) {
                // Adding a document to Firestore returns a Database Reference to that specific object if successful.
                // use this reference to get the documentID - we use this to refer to documents in FIrestore
                entry.id = journalEntryRef.documentID
            }
        } catch {
            print("Failed to add journal entry")
        }
        
        return entry
    }
    
    func deleteJournalEntry(journalEntry: JournalEntry){
        // check if they have a valid ID.
        // If they do, use it with the database references to delete them.
        if let entryID = journalEntry.id {
            journalEntryRef?.document(entryID).delete()
        }
    }
    
    // CoreData stuff =======================================
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
    // ======================================================
    
    
    // MARK: - Firebase Controller Specific Methods
    
    // called once we have received an authentication result from Firebase.
    func setupApplicationListener(){
        // get Firestore reference to the applicationDetail collection
        applicationRef = database.collection("applicationDetail")
        
        // set up a snapshotListener to listen for ALL changes on applicationDetail collection
        applicationRef?.addSnapshotListener() { (querySnapshot, error) in
            // closure to be called whenever a change occurs
            // this closure will execute every single time a change is detected on the applicationDetail collection
            
            // ensure that the snapshot is valid (i.e. not nil)
            guard let querySnapshot = querySnapshot else {
                print("Failed to fetch documents with error: \(String(describing: error))")
                return
            }
            // If querySnapshot is valid, call parseHeroesSnapshot method to handle parsing changes made on Firestore
            self.parseApplicationSnapshot(snapshot: querySnapshot)
        }
    }
    
    func setupJournalEntryListener(){
        // get Firestore reference to the journalEntry collection
        journalEntryRef = database.collection("journalEntry")
        
        // set up a snapshotListener to listen for ALL changes on journalEntry collection
        journalEntryRef?.addSnapshotListener() { (querySnapshot, error) in
            // closure to be called whenever a change occurs
            // this closure will execute every single time a change is detected on the applicationDetail collection
            
            // ensure that the snapshot is valid (i.e. not nil)
            guard let querySnapshot = querySnapshot else {
                print("Failed to fetch documents with error: \(String(describing: error))")
                return
            }
            // If querySnapshot is valid, call parseHeroesSnapshot method to handle parsing changes made on Firestore
            self.parseJournalEntrySnapshot(snapshot: querySnapshot)
        }
    }
    
    // parsing application details
    // parse the snapshot and make any changes as required to our local properties and call local listeners
    func parseApplicationSnapshot(snapshot: QuerySnapshot){  // snapshot provided from firebase
        
        // create a for-each loop that goes through each document change in the snapshot.
        // documentChanges - only pay attention to changes as it allows us to easily handle different behaviour based on the type of change that has been made
        snapshot.documentChanges.forEach { (change) in
            
            print("Raw Document Data: \(change.document.data())")
            
            // decode the document's data as an ApplicationDetail object using codable
            var app: ApplicationDetail
            do {
                app = try change.document.data(as: ApplicationDetail.self)
            } catch {
                fatalError("Unable to decode application details: \(error.localizedDescription); \(String(describing: error))")
//                print("Error decoding application details: \(error.localizedDescription)")
            }
            
            // we'll be focussing on added, modified, and removed changes
            if change.type == .added {
                applicationList.insert(app, at: Int(change.newIndex))
                // If change type is added, insert it into the array at the appropriate place
                
            } else if change.type == .modified {
                applicationList.remove(at: Int(change.oldIndex))
                applicationList.insert(app, at: Int(change.newIndex))
                // If change type is modified, remove and re-add the newly modified hero at the new location
                
            } else if change.type == .removed {
                applicationList.remove(at: Int(change.oldIndex))
                // If change type is deleted, delete the element at the given location
            }
            
            // once all changes have been handled,
            // use multicast delegate's invoke method to call onAllApplicationDetailsChange on each listener
            listeners.invoke { (listener) in
                if listener.listenerType == ListenerType.applicationDetails {
                    listener.onAllApplicationDetailsChange(change: .update, applicationDetails: applicationList)
                }
            }
        }
    }
    
    func parseJournalEntrySnapshot(snapshot: QuerySnapshot){  // snapshot provided from firebase
        
        // create a for-each loop that goes through each document change in the snapshot.
        // documentChanges - only pay attention to changes as it allows us to easily handle different behaviour based on the type of change that has been made
        snapshot.documentChanges.forEach { (change) in
            
            // decode the document's data as an JournalEntry object using codable
            var entry: JournalEntry
            do {
                entry = try change.document.data(as: JournalEntry.self)
            } catch {
                fatalError("Unable to decode journal entry: \(error.localizedDescription); \(String(describing: error))")
            }
            
            // we'll be focussing on added, modified, and removed changes
            if change.type == .added {
                journalEntryList.insert(entry, at: Int(change.newIndex))
                // If change type is added, insert it into the array at the appropriate place
                
            } else if change.type == .modified {
                journalEntryList.remove(at: Int(change.oldIndex))
                journalEntryList.insert(entry, at: Int(change.newIndex))
                // If change type is modified, remove and re-add the newly modified hero at the new location
                
            } else if change.type == .removed {
                journalEntryList.remove(at: Int(change.oldIndex))
                // If change type is deleted, delete the element at the given location
            }
            
            // once all changes have been handled,
            // use multicast delegate's invoke method to call onAllJournalEntryChange on each listener
            listeners.invoke { (listener) in
                if listener.listenerType == ListenerType.journalEntry {
                    listener.onAllJournalEntryChange(change: .update, journalEntry: journalEntryList)
                }
            }
        }
    }
    
    // CoreData stuff =======================================
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
    // ======================================================
}
