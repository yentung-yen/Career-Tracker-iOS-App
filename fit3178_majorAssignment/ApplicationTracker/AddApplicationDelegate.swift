//
//  AddApplicationDelegate.swift
//  fit3178_majorAssignment
//
//  Created by Chin Yen Tung on 1/5/2024.
//

import Foundation

// to create a delegate, we use the "protocol" keyword
// inherit from the AnyObject class
protocol AddApplicationDelegate: AnyObject {
    // method stub to say whether it can successfully add an application
    func addApplication(_ newApplication: ApplicationDetails) -> Bool
    
    // Stubs are commonly used as placeholders for implementation of a known interface
    // a piece of code used to stand in for some other programming functionality.
    // A stub may simulate the behavior of existing code or be a temporary substitute for yet-to-be-developed code.
}
