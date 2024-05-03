//
//  FirebaseController.swift
//  jobApplication_prepTrack_app
//
//  Created by Chin Yen Tung on 2/5/2024.
//

import UIKit
import Firebase
import FirebaseFirestoreSwift

class FirebaseController: NSObject, DatabaseProtocol {
    func cleanup() {}
    
    var authController: Auth
    var database: Firestore
    var applicationRef: CollectionReference?
    var journalEntryRef: CollectionReference?
    var currentUser: FirebaseAuth.User?
    var listeners = MulticastDelegate<DatabaseListener>()
    
    var applicationList: [ApplicationDetail]
    var journalEntryList: [JournalEntry]
    
    override init(){
        // configure and initialize each of the Firebase frameworks we plan to use
        FirebaseApp.configure()
        authController = Auth.auth()
        database = Firestore.firestore()
        
        applicationList = [ApplicationDetail]()
        journalEntryList = [JournalEntry]()
        
        super.init()
        
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
}
