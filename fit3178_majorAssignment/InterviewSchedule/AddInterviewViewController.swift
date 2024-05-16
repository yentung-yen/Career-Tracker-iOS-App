//
//  AddInterviewViewController.swift
//  jobApplication_prepTrack_app
//
//  Created by Chin Yen Tung on 16/5/2024.
//

import UIKit

class AddInterviewViewController: UIViewController {
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var startDateTime: UIDatePicker!
    @IBOutlet weak var endDateTime: UIDatePicker!
    @IBOutlet weak var vidLinkTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var notifDatePicker: UIDatePicker!
    @IBOutlet weak var notesTextField: UITextField!
    
    var selectedDate: Int?
    var selectedMonth: Int?
    var selectedYear: Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set start date time and notification date time
        var dateComponents = DateComponents()
        dateComponents.year = selectedYear
        dateComponents.month = selectedMonth
        dateComponents.day = selectedDate
        
        let currentDateTime = Date()
        let calendar = Calendar.current
        let currentTimeComponents = calendar.dateComponents([.hour, .minute, .second], from: currentDateTime)

        dateComponents.hour = currentTimeComponents.hour
        dateComponents.minute = currentTimeComponents.minute
        dateComponents.second = currentTimeComponents.second
        
        if let date = calendar.date(from: dateComponents) { // create date object
            startDateTime.date = date  // set date picker to created date
            notifDatePicker.date = date
        }
        
        // set end date time
        let endTime = calendar.date(byAdding: .minute, value: 20, to: currentDateTime)
        dateComponents.hour = calendar.component(.hour, from: endTime!)
        dateComponents.minute = calendar.component(.minute, from: endTime!)
        dateComponents.second = calendar.component(.second, from: endTime!)
        
        if let date = calendar.date(from: dateComponents) { // create date object
            endDateTime.date = date  // set date picker to created date
        }
    }
    
    @IBAction func onSaveInterview(_ sender: Any) {
        
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
