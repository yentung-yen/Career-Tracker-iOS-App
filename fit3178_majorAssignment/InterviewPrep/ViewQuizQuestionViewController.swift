//
//  ViewQuizQuestionViewController.swift
//  jobApplication_prepTrack_app
//
//  Created by Chin Yen Tung on 10/5/2024.
//

import UIKit

struct Answer {
    var text: String
    var isCorrect: Bool
    var onViewAnswerClick: Bool = false
}

class ViewQuizQuestionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var currentQuizQuestionDetails: QuestionData?
    var oriAnswerList: [String: String?]?
    var answerList = [Answer]()
    var correctAnswerList = [Answer]()
    
    @IBOutlet weak var quizCategoryLabel: UILabel!
    @IBOutlet weak var difficultyLabel: UILabel!
    @IBOutlet weak var questionTextView: UITextView!
    @IBOutlet weak var answerUITableView: UITableView!
    
    // Constants for Table
    let SECTION_ANSWERS = 0
    let CELL_ANSWER = "answerCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        answerUITableView.dataSource = self
        answerUITableView.delegate = self
        answerUITableView.contentInset = UIEdgeInsets(top: -30, left: 0, bottom: 0, right: 0)
        
        quizCategoryLabel.text = currentQuizQuestionDetails?.questionCategory?.uppercased()
        difficultyLabel.text = currentQuizQuestionDetails?.difficulty
        questionTextView.text = currentQuizQuestionDetails?.question
        
        getAnswerList()
    }
    
    @IBAction func onViewAnswer(_ sender: Any) {
        for i in 0...answerList.count - 1 {
            answerList[i].onViewAnswerClick = true
        }
        answerUITableView.reloadData()
    }
    
    func getAnswerList() {
        oriAnswerList = currentQuizQuestionDetails?.answers
        
        for (key, value) in oriAnswerList! where value != nil {
            // check if this answer is correct
            let ansKey = key + "_correct"
            var isCorrect = false
            
            if currentQuizQuestionDetails?.correctAnswers[ansKey] == "true" {
                isCorrect = true
            }
            
            // add this answer to the list
            let answer = Answer(text: value!, isCorrect: isCorrect)
            answerList.append(answer)
        }
    }

    
    // MARK: - Table Controllers
    
    // determines the number of sections in the Table View
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // We refer to this method as “tableViewNumberOfRowsInSection"
    // determines the number of rows in a specified section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return answerList.count
    }
    
    // creates the cells to be displayed to the user
    // calls the dequeReusableCell method and provide it an identifier - identifier must match a Reuse Identifier we created on the storyboard
    // calls indexPath to generate a cell object - index path specifies a section and row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // indexPath contains the current row number which will correspond to a specific answer in our array
        // because we’ve told the table view that the number of rows in this section = array length.
        let answer = answerList[indexPath.row]
        
        let answerCell = tableView.dequeueReusableCell(withIdentifier: CELL_ANSWER, for: indexPath)
        answerCell.selectionStyle = .none  // disable default selection color
        
        // change cell background colour to show corect answer if view answer button is clicked
        if answer.onViewAnswerClick && answer.isCorrect {
            answerCell.backgroundColor = UIColor(red: 0.56, green: 0.93, blue: 0.56, alpha: 0.70)
        } else if answer.onViewAnswerClick && answer.isCorrect == false {
            answerCell.backgroundColor = UIColor(red: 0.93, green: 0.56, blue: 0.56, alpha: 0.70)
        } else {
            answerCell.backgroundColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1.00)
        }
        
        var content = answerCell.defaultContentConfiguration()
        content.text = answer.text
        answerCell.contentConfiguration = content
        
        return answerCell     // return a cell object
    }
    

    // allows us to specify whether a certain row can be edited by the user (update, delete).
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Check the section of the indexPath
        if indexPath.section == SECTION_ANSWERS {
            return true // Allow editing
        } else {
            // Info Cells section
            return false // Dont allow editing
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.backgroundColor = UIColor(red: 0.60, green: 0.60, blue: 0.60, alpha: 1.00)
        }
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.backgroundColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1.00)
        }
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
