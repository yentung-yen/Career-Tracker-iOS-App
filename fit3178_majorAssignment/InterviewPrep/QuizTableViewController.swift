//
//  InterviewQuestionBankTableViewController.swift
//  jobApplication_prepTrack_app
//
//  Created by Chin Yen Tung on 9/5/2024.
//

import UIKit

class QuizTableViewController: UITableViewController {
    let SECTION_TITLE = 0
    let SECTION_QUESTION = 1
    
    let CELL_TITLE = "titleCell"
    let CELL_QUESTION = "questionCell"
    
    var API_KEY = "nAWGuORbcb5KqDoG4bhDpuG6Nce8jjLoOVGvZlac"
    var category: String = ""
    
    var questionsList = [QuestionData]() // to show list of questions
    
    // Activity Indicator View to display a spinning animation used to indicate loading
    var indicator = UIActivityIndicatorView()

    override func viewDidLoad() {
        super.viewDidLoad()

        // set up and add our indicator to the view controller’s view
        // Add a loading indicator view
        indicator.style = UIActivityIndicatorView.Style.large
        indicator.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(indicator)
        
        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)
        ])
        
        indicator.startAnimating()
        // call the requestQuestionData method to handle the request
        // Because requestQuestionData method is async, we must encapsulate it within a Task.
        Task {
            await requestQuestionData()
        }
    }
    
    
    // MARK: - Fetch data from API
    
    func requestQuestionData() async {
        var searchURLComponents = URLComponents()
        searchURLComponents.scheme = "https"
        searchURLComponents.host = "quizapi.io"
        searchURLComponents.path = "/api/v1/questions"
        searchURLComponents.queryItems = [
            URLQueryItem(name: "apiKey", value: "\(API_KEY)"),
            URLQueryItem(name: "category", value: "\(category)")
        ]
        
        guard let requestURL = searchURLComponents.url else {
            print("Invalid URL.")
            return
        }
        
        let urlRequest = URLRequest(url: requestURL)
        
        // create the data task and execute it
        do {
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            
            // Once we receive a response and the function begins executing again:
            // tell our loading indicator to stop animating
            indicator.stopAnimating()
            
//            // print raw JSON string for debugging
//            if let jsonString = String(data: data, encoding: .utf8) {
//                print(jsonString)
//                print(requestURL)
//            }
            
            // With a response back we should attempt to parse the data
            // parsing data through decoder can throw error so need do... catch {}
            // we can use the outer do... catch() block too.
            // but we want to use a second one so that the rest of the function can occur even if this fails
            do {
                let decoder = JSONDecoder()     // create a JSONDecoder instance
                let questionData = try decoder.decode([QuestionData].self, from: data)
//                print(questionData)

                // Append new books to the array
                questionsList.append(contentsOf: questionData)
//                print(questionsList)
                
                // Reload the tableView on the main thread
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
            } catch {
                print("Error decoding JSON: \(error)")
            }
        } catch {
            print("URLSession Error: \(error)")
        }
    }

    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
            case SECTION_TITLE:
                return 1
                
            case SECTION_QUESTION:
                return questionsList.count
                
            default:
                return 0
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == SECTION_QUESTION {
            let cell = tableView.dequeueReusableCell(withIdentifier: CELL_QUESTION, for: indexPath)
            
            let question = questionsList[indexPath.row]
            cell.textLabel?.text = "\(question.question!)\n"
            cell.detailTextLabel?.text = question.difficulty
            
            // allow the label to display multiple lines of text
            // causes no limit to the number of lines that the text label can display
            cell.textLabel?.numberOfLines = 0
            
            // specify how to break the line when the text exceeds the available space
            // allow label to wrap the text to the next line if it exceeds the available space
            cell.textLabel?.lineBreakMode = .byWordWrapping
            
            return cell     // return a cell object
            
        } else {
            let titleCell = tableView.dequeueReusableCell(withIdentifier: CELL_TITLE, for: indexPath)
            
            titleCell.textLabel?.text = "\(category.capitalized) Quiz"
            titleCell.detailTextLabel?.text = "\(questionsList.count) Random Questions"
            
            return titleCell
        }
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "viewQuestionSegue" {
            if let indexPath = tableView.indexPathForSelectedRow {
                if let destinationVC = segue.destination as? ViewQuizQuestionViewController {
                    destinationVC.currentQuizQuestionDetails = questionsList[indexPath.row]
                }
            }
        }
    }
    

}
