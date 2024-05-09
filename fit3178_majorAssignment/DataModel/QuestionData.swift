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
    
//    // add Codable to conform to Encodable and Decodable which encodes & decodes data
//    struct Answers: Codable {
//        var answerA: String?
//        var answerB: String?
//        var answerC: String?
//        var answerD: String?
//        var answerE: String?
//        var answerF: String?
//
//        enum CodingKeys: String, CodingKey {
//            case answerA = "answer_a"
//            case answerB = "answer_b"
//            case answerC = "answer_c"
//            case answerD = "answer_d"
//            case answerE = "answer_e"
//            case answerF = "answer_f"
//        }
//    }
//
//    struct CorrectAnswers: Codable {
//        var answerACorrect: Bool
//        var answerBCorrect: Bool
//        var answerCCorrect: Bool
//        var answerDCorrect: Bool
//        var answerECorrect: Bool
//        var answerFCorrect: Bool
//
//        enum CodingKeys: String, CodingKey {
//            case answerACorrect = "answer_a_correct"
//            case answerBCorrect = "answer_b_correct"
//            case answerCCorrect = "answer_c_correct"
//            case answerDCorrect = "answer_d_correct"
//            case answerECorrect = "answer_e_correct"
//            case answerFCorrect = "answer_f_correct"
//        }
//    }
    
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
