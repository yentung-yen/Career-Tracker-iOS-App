//
//  QuestionBank.swift
//  jobApplication_prepTrack_app
//
//  Created by Chin Yen Tung on 9/5/2024.
//

import UIKit

// https://developer.apple.com/documentation/foundation/archives_and_serialization/encoding_and_decoding_custom_types

class QuestionData: NSObject, Decodable {
    var questionId: Int?
    var question: String?
    var questionDescription: String?
    var answers: [String: String?]
    var correctAnswers: [String: String]
    var explanation: String?
    var questionCategory: String?
    var difficulty: String?
    
    private enum QuestionKeys: String, CodingKey {
        case questionId = "id"
        case question
        case questionDescription = "description"
        case answers
        case correctAnswers = "correct_answers"
        case explanation
        case questionCategory = "category"
        case difficulty
    }
    
    // initializer - this initializer can throw an error
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: QuestionKeys.self)
            
        // Decode each property from the decoder's container
        questionId = try? container.decode(Int.self, forKey: .questionId)
        question = try? container.decode(String.self, forKey: .question)
        questionDescription = try? container.decode(String.self, forKey: .questionDescription)
        
        answers = try container.decode([String: String?].self, forKey: .answers)
        correctAnswers = try container.decode([String: String].self, forKey: .correctAnswers)
        
        explanation = try? container.decode(String.self, forKey: .explanation)
        questionCategory = try? container.decode(String.self, forKey: .questionCategory)
        difficulty = try? container.decode(String.self, forKey: .difficulty)
    }
}
