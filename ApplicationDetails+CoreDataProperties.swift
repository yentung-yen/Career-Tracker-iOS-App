//
//  ApplicationDetails+CoreDataProperties.swift
//  fit3178_majorAssignment
//
//  Created by Chin Yen Tung on 1/5/2024.
//
//

import Foundation
import CoreData

enum JobMode: Int32 {
    case Hybrid = 0
    case InPerson = 1
    case Online = 2
}

enum ApplicationStatus: Int32 {
    case Applied = 0
    case OA = 1
    case Interview = 2
    case Offered = 3
}

extension ApplicationDetails {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ApplicationDetails> {
        return NSFetchRequest<ApplicationDetails>(entityName: "ApplicationDetails")
    }

    @NSManaged public var jobTitle: String?
    @NSManaged public var company: String?
    @NSManaged public var jobLocation: String?
    @NSManaged public var jobMode: Int32
    @NSManaged public var salary: Double
    @NSManaged public var postURL: String?
    @NSManaged public var applicationStatus: Int32
    @NSManaged public var notes: String?

}

extension ApplicationDetails : Identifiable {

}

// setter and getter methods
extension ApplicationDetails {
    var applicationJobMode: JobMode {
        get {
            return JobMode(rawValue: self.jobMode)!
        }
        set {
            self.jobMode = newValue.rawValue
        }
    }
    var applicationApplicationStatus: ApplicationStatus {
        get {
            return ApplicationStatus(rawValue: self.applicationStatus)!
        }
        set {
            self.applicationStatus = newValue.rawValue
        }
    }
}
