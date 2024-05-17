//
//  InterviewScheduleDetail+CoreDataProperties.swift
//  jobApplication_prepTrack_app
//
//  Created by Chin Yen Tung on 17/5/2024.
//
//

import Foundation
import CoreData


extension InterviewScheduleDetail {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<InterviewScheduleDetail> {
        return NSFetchRequest<InterviewScheduleDetail>(entityName: "InterviewScheduleDetail")
    }

    @NSManaged public var interviewTitle: String?
    @NSManaged public var interviewStartDatetime: Date?
    @NSManaged public var interviewEndDatetime: Date?
    @NSManaged public var interviewVideoLink: String?
    @NSManaged public var interviewLocation: String?
    @NSManaged public var interviewNotifDatetime: Date?
    @NSManaged public var interviewNotes: String?

}

extension InterviewScheduleDetail : Identifiable {

}
