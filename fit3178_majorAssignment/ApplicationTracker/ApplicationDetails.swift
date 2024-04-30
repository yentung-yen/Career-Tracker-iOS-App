//
//  ApplicationDetails.swift
//  fit3178_majorAssignment
//
//  Created by Chin Yen Tung on 1/5/2024.
//

import UIKit

enum JobMode: Int {
    case Hybrid = 0
    case InPerson = 1
    case Online = 2
}

enum ApplicationStatus: Int {
    case Applied = 0
    case OA = 1
    case Interview = 2
    case Offered = 3
}

class ApplicationDetails: NSObject {
    var jobTitle: String?
    var company: String?
    var jobLocation: String?
    var jobMode: JobMode?
    var salary: Int?
    var postURL: String?
    var applicationStatus: ApplicationStatus?
    var notes: String?
    
    init(jobTitle: String? = nil, company: String? = nil, jobLocation: String? = nil, jobMode: JobMode? = nil, salary: Int? = nil, postURL: String? = nil, applicationStatus: ApplicationStatus? = nil, notes: String? = nil) {
        self.jobTitle = jobTitle
        self.company = company
        self.jobLocation = jobLocation
        self.jobMode = jobMode
        self.salary = salary
        self.postURL = postURL
        self.applicationStatus = applicationStatus
        self.notes = notes
    }
}
