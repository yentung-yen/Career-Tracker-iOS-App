//
//  ViewQuizQuestionViewController.swift
//  jobApplication_prepTrack_app
//
//  Created by Chin Yen Tung on 10/5/2024.
//

import UIKit

class ViewQuizQuestionViewController: UIViewController {
    var currentQuizQuestionDetails: QuestionData?
    
    @IBOutlet weak var difficultyLabel: UILabel!
    @IBOutlet weak var questionTextView: UITextView!
    @IBOutlet weak var descLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        questionTextView.text = currentQuizQuestionDetails?.question
        difficultyLabel.text = currentQuizQuestionDetails?.difficulty
        descLabel.text = currentQuizQuestionDetails?.questionDescription
    }
    
    @IBAction func onViewAnswer(_ sender: Any) {
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
