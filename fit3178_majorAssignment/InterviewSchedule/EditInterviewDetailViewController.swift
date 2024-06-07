//
//  EditInterviewDetailViewController.swift
//  jobApplication_prepTrack_app
//
//  Created by Chin Yen Tung on 8/6/2024.
//

import UIKit

class EditInterviewDetailViewController: UIViewController {

    @IBOutlet weak var interviewTextField: UITextField!
    @IBOutlet weak var interviewStartDatePicker: UIDatePicker!
    @IBOutlet weak var interviewEndDatePicker: UIDatePicker!
    @IBOutlet weak var interviewVidConference: UITextField!
    @IBOutlet weak var interviewLocation: UITextField!
    @IBOutlet weak var interviewNotifDatePicker: UIDatePicker!
    @IBOutlet weak var interviewNotes: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
