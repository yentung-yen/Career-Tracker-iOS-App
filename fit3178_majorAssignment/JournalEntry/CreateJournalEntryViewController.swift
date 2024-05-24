//
//  CreateJournalEntryViewController.swift
//  jobApplication_prepTrack_app
//
//  Created by Chin Yen Tung on 2/5/2024.
//

import UIKit

class CreateJournalEntryViewController: UIViewController {

    @IBOutlet weak var entryTitleTextField: UITextField!
    @IBOutlet weak var entryDatePicker: UIDatePicker!
    @IBOutlet weak var entryCategories: UITextField!
    @IBOutlet weak var entryDescTextField: UITextField!
    
    weak var databaseController: DatabaseProtocol?
    var categoryList: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let appDelegate = UIApplication.shared.delegate as? AppDelegate // get access to the AppDelegate
        databaseController = appDelegate?.firebaseDatabaseController    // store a reference to the databaseController
    }
    
    @IBAction func onAddEntryClick(_ sender: Any) {
        //TODO: validate date picker
        // validate the user input
        guard let title = entryTitleTextField.text, let category = entryCategories.text, let desc = entryDescTextField.text else {
            return
        }
        // - ensure name and abilities are not empty
        if title.isEmpty || category.isEmpty || desc.isEmpty {
            var errorMsg = "Please ensure all fields are filled:\n"
            
            if title.isEmpty {
                errorMsg += "- Title must be provided\n"
            }
            if category.isEmpty {
                errorMsg += "- Category must be provided\n"
            }
            if desc.isEmpty {
                errorMsg += "- Description must be provided\n"
            }
            displayMessage(title: "Missing Fields", message: errorMsg)
            return
        }
        
        // format date and convert to string
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current   // used to ensure that app adapts to user's language and region settings
        dateFormatter.dateFormat = "dd-MMM-yyyy" // set date format
        let dateString = dateFormatter.string(from: entryDatePicker.date) // convert to string
        
        // TODO: handle category list
        categoryList.append(category)
        
        let _ = databaseController?.addJournalEntry(entryTitle: title, entryDate: dateString, entryCategories: categoryList, entryDes: desc)
        navigationController?.popViewController(animated: true)
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
