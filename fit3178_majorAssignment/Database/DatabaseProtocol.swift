//
//  DatabaseProtocol.swift
//  fit3178_majorAssignment
//
//  Created by Chin Yen Tung on 1/5/2024.
//

import Foundation

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
    case journal
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
    func onAllApplicationDetailsChange(change: DatabaseChange, applicationDetails: [ApplicationDetails])
    // ===================================================================
}

// This protocol defines all the behaviour that a database must have.
// this will be the public facing methods that can be accessed by other parts of the application.
protocol DatabaseProtocol: AnyObject {
    func cleanup()
    func addListener(listener: DatabaseListener)
    func removeListener(listener: DatabaseListener)
    
    // functionality to add, delete applications
    func addApplication(jobTitle: String, company: String, jobLocation: String, jobMode: JobMode, salary: Int32, postURL: String, applicationStatus: ApplicationStatus, notes: String) -> ApplicationDetails
    func deleteApplication(applicationDetails: ApplicationDetails)
}
