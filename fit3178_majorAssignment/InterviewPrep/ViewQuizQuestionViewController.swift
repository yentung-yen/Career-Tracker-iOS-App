//
//  ViewQuizQuestionViewController.swift
//  jobApplication_prepTrack_app
//
//  Created by Chin Yen Tung on 10/5/2024.
//

import UIKit

class ViewQuizQuestionViewController: UIViewController {
    var currentQuizQuestionDetails: QuestionData?
    var correctAnswerList: [String?] = []
    var answerList: [String: String?]?
    
    @IBOutlet weak var quizCategoryLabel: UILabel!
    @IBOutlet weak var difficultyLabel: UILabel!
    @IBOutlet weak var questionTextView: UITextView!
    @IBOutlet weak var answerLabel: UILabel!
    @IBOutlet weak var answerTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        quizCategoryLabel.text = currentQuizQuestionDetails?.questionCategory?.uppercased()
        difficultyLabel.text = currentQuizQuestionDetails?.difficulty
        questionTextView.text = currentQuizQuestionDetails?.question
    }
    
    @IBAction func onViewAnswer(_ sender: Any) {
        getAnswer()
        
        var concatAns = ""
        
        for ans in correctAnswerList {
            concatAns = concatAns + ans! + "\n"
        }
        
        answerLabel.text = "Answer"
        answerTextView.text = concatAns
//        print(currentQuizQuestionDetails?.answers)
//        print(currentQuizQuestionDetails?.correctAnswers)
//        print(currentQuizQuestionDetails?.explanation)
    }
    
    func getAnswer() {
        answerList = currentQuizQuestionDetails?.answers
        
        for (key, value) in answerList! where value != nil {
            let ansKey = key + "_correct"
            
            if currentQuizQuestionDetails?.correctAnswers[ansKey] == "true" {
                print(value)
                correctAnswerList.append(value)
            }
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "viewQuestionAnswerSegue" {
            if let destinationVC = segue.destination as? ViewQuizQuestionAnswerViewController {
                destinationVC.currentQuizQuestionDetails = currentQuizQuestionDetails
            }
        }
    }
}
