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
        entryTitleLabel.text = currentJournalEntry?.journalEntryTitle
        entryDateLabel.text = currentJournalEntry?.journalEntryDate
        entryCategoryButton.setTitle(currentJournalEntry?.journalEntryCategory, for: .normal)
        entryDescTextView.text = currentJournalEntry?.journalEntryDesc
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
    

}
