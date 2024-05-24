//
//  DatabaseProtocol.swift
//  fit3178_majorAssignment
//
//  Created by Chin Yen Tung on 1/5/2024.
//

import Foundation
import FirebaseAuth

// used to define what type of change has been done to the database
enum DatabaseChange {
    case add
    case remove
    case update
}

// The database we're building has multiple sets of data that each require their own specific behaviour to handle
// We specify the type of data each of our listeners deals with
enum ListenerType {
    case applicationDetails
    case journalEntry
    case interviewSchedule
}

// define the listener
// this protocol defines the delegate we will use for receiving messages from the database
protocol DatabaseListener: AnyObject {
    // specify listener type
    var listenerType: ListenerType {get set}
    
    // =============================================
    // each of the onChange methods returns a change type
    // this enables us to slightly change the behaviour based on the kind of change that has occurred to the database
    
    // method for when a change to any of the application details has occurred
    func onAllApplicationDetailsChange(change: DatabaseChange, applicationDetails: [ApplicationDetail])
    
    // method for when a change of journal entry has occurred
    func onAllJournalEntryChange(change: DatabaseChange, journalEntry: [JournalEntry])
    
    func onAllInterviewScheduleChange(change: DatabaseChange, interviewScheduleDetail: [InterviewScheduleDetail])
    // ===================================================================
}

// This protocol defines all the behaviour that a database must have.
// this will be the public facing methods that can be accessed by other parts of the application.
protocol DatabaseProtocol: AnyObject {
    func cleanup()
    func addListener(listener: DatabaseListener)
    func removeListener(listener: DatabaseListener)
    
    // functionality to add, delete applications
    func addApplication(jobTitle: String, company: String, jobLocation: String, jobMode: JobMode, salary: Double, postURL: String, applicationStatus: ApplicationStatus, notes: String) -> ApplicationDetail
    func deleteApplication(applicationDetails: ApplicationDetail)
    
    // functionality to add, delete journal entries
    func addJournalEntry(entryTitle: String, entryDate: String, entryCategories: [String], entryDes: String) -> JournalEntry
    func deleteJournalEntry(journalEntry: JournalEntry)
    
    // functionality to add, delete interview schedule
    func addInterviewSchedule(interviewTitle: String, interviewStartDatetime: Date, interviewEndDatetime: Date, interviewVideoLink: String, interviewLocation: String, interviewNotifDatetime: Date, interviewNotes: String) -> InterviewScheduleDetail
    func deleteInterviewSchedule(interviewScheduleDetail: InterviewScheduleDetail)
    
    // authentication functions
    var successfulSignUp: Bool {get set}    // variable to tell us if a sign up was successful or not
    func createUser(email: String, password: String, completion: @escaping (AuthDataResult?, Error?) -> Void)
    func loginUser(email: String, password: String, completion: @escaping (AuthDataResult?, Error?) -> Void)
    func signOutUser()
//    func addUser(name: String) -> User
    func activeUserExist() -> Bool
    
    func setupApplicationListener()
    func setupJournalEntryListener()
}
