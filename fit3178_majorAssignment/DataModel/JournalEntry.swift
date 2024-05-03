//
//  JournalEntry.swift
//  jobApplication_prepTrack_app
//
//  Created by Chin Yen Tung on 2/5/2024.
//

import UIKit
import FirebaseFirestoreSwift

class JournalEntry: NSObject, Codable {
    @DocumentID var id: String?
    var entryDate: String?
    var entryDes: String?
    var entryTitle: String?
    var entryCategories: [String]?
}
