//
//  User.swift
//  jobApplication_prepTrack_app
//
//  Created by Chin Yen Tung on 24/5/2024.
//

import UIKit
import FirebaseFirestoreSwift

class User: NSObject, Codable {
    @DocumentID var id: String?
    var name: String?
}
