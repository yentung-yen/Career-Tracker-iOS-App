//
//  ViewJournalEntryViewController.swift
//  jobApplication_prepTrack_app
//
//  Created by Chin Yen Tung on 2/5/2024.
//

import UIKit

class ViewJournalEntryViewController: UIViewController {
    var currentJournalEntry: JournalEntry?

    @IBOutlet weak var entryTitleLabel: UILabel!
    @IBOutlet weak var entryDateLabel: UILabel!
    @IBOutlet weak var entryCategoryButton: UIButton!
    @IBOutlet weak var entryDescTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        entryTitleLabel.text = currentJournalEntry?.entryTitle
        entryDateLabel.text = currentJournalEntry?.entryDate
        // TODO: category list
        print(currentJournalEntry?.entryCategories ?? "idk what im doing - ViewJournalEntryViewController")
        entryDescTextView.text = currentJournalEntry?.entryDes
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
    

}
