//
//  QuizCategory.swift
//  jobApplication_prepTrack_app
//
//  Created by Chin Yen Tung on 10/5/2024.
//

import UIKit

// https://quizapi.io/api/v1/categories?apiKey=API_KEY

class QuizCategory: NSObject, Decodable {
    var catId: Int?
    var catName: String?
    
    private enum CategoryKeys: String, CodingKey {
        case catId = "id"
        case catName = "name"
    }
    
    // initializer - this initializer can throw an error
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CategoryKeys.self)
            
        // Decode each property from the decoder's container
        catId = try? container.decode(Int.self, forKey: .catId)
        catName = try? container.decode(String.self, forKey: .catName)
    }
}
