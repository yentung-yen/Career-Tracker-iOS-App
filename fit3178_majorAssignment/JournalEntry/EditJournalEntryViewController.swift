//
//  EditJournalEntryViewController.swift
//  jobApplication_prepTrack_app
//
//  Created by Chin Yen Tung on 2/5/2024.
//

import UIKit

class EditJournalEntryViewController: UIViewController {
    
    var currentJournalEntry: JournalEntry?

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var categoryTextField: UITextField!
    @IBOutlet weak var descTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TODO: get date in string
        
        // TODO: handle categories

        titleTextField.text = currentJournalEntry?.entryTitle
        descTextField.text = currentJournalEntry?.entryDes
    }
    
    // TODO: implement code to edit journal details

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
