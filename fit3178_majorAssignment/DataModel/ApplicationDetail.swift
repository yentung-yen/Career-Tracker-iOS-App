//
//  ApplicationDetail.swift
//  jobApplication_prepTrack_app
//
//  Created by Chin Yen Tung on 2/5/2024.
//

import UIKit
import FirebaseFirestoreSwift

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

class ApplicationDetail: NSObject, Codable {
    @DocumentID var id: String?
    var jobTitle: String?
    var company: String?
    var jobLocation: String?
    var jobMode: Int?
    var salary: Double?
    var postURL: String?
    var applicationStatus: Int?
    var notes: String?
}

// create CodingKeys to ensure that enums are excluded from the encode and decode process
enum CodingKeys: String, CodingKey {
    case id
    case jobTitle
    case company
    case jobLocation
    case jobMode
    case salary
    case postURL
    case applicationStatus
    case notes
}

// setter and getter methods
extension ApplicationDetail {
    var applicationJobMode: JobMode {
        get {
            return JobMode(rawValue: self.jobMode!)!
        }
        set {
            self.jobMode = newValue.rawValue
        }
    }
    var applicationApplicationStatus: ApplicationStatus {
        get {
            return ApplicationStatus(rawValue: self.applicationStatus!)!
        }
        set {
            self.applicationStatus = newValue.rawValue
        }
    }
}
