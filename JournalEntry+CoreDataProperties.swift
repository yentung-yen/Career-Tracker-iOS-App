//
//  JournalEntry+CoreDataProperties.swift
//  jobApplication_prepTrack_app
//
//  Created by Chin Yen Tung on 2/5/2024.
//
//

import Foundation
import CoreData


extension JournalEntry {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<JournalEntry> {
        return NSFetchRequest<JournalEntry>(entityName: "JournalEntry")
    }

    @NSManaged public var journalEntryDate: String?
    @NSManaged public var journalEntryDesc: String?
    @NSManaged public var journalEntryTitle: String?
    @NSManaged public var journalEntryCategory: String?

}

extension JournalEntry : Identifiable {

}
