//
//  AddJournalEntryDelegate.swift
//  jobApplication_prepTrack_app
//
//  Created by Chin Yen Tung on 2/5/2024.
//

import Foundation

// to create a delegate, we use the "protocol" keyword
// inherit from the AnyObject class
protocol AddJournalEntryDelegate: AnyObject {
    // method stub to say whether it can successfully add an application
    func addJournalEntry(_ newApplication: ApplicationDetails) -> Bool
    
    // Stubs are commonly used as placeholders for implementation of a known interface
    // a piece of code used to stand in for some other programming functionality.
    // A stub may simulate the behavior of existing code or be a temporary substitute for yet-to-be-developed code.
}
