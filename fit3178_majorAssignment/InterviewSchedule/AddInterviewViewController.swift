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
    
    weak var databaseController: DatabaseProtocol?
    
    // ask for app delegate for setting notifications
    lazy var appDelegate = {
        guard let appDelegate =  UIApplication.shared.delegate as?  AppDelegate else {
            fatalError("No AppDelegate")
        }
        return appDelegate
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // get access to the AppDelegate
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        // store a reference to the coreDataDatabaseController
        databaseController = appDelegate?.databaseController
        
        // notification set up
        if let response = UserDefaults.standard.string(forKey: "response") {
            print("There was a stored response: \(response)")
        }
        else {
            print("No stored response")
        }
        
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
        // validate the user input
        guard let title = titleTextField.text else {
            return
        }
        // - ensure title is not empty
        if title.isEmpty {
            var errorMsg = "Please ensure these fields are filled:\n"
            
            if title.isEmpty {
                errorMsg += "- Title must be provided\n"
            }
            
            displayMessage(title: "Missing Fields", message: errorMsg)
            return
        }
        // validate start and end date chosen
        if endDateTime.date < startDateTime.date {
            displayMessage(title: "Date Error", message: "Interview end date is before start date")
            return
        }
        
        // set default text
        guard let vidLink = vidLinkTextField.text == "" ? "No Video Conferencing Link Entered": vidLinkTextField.text else { return  }
        guard let interviewLocation = locationTextField.text == "" ? "No Location Entered": locationTextField.text else { return }
        guard let notes = notesTextField.text == "" ? "No Notes Entered": notesTextField.text else { return }
        
        let _ = databaseController?.addInterviewSchedule(interviewTitle: title, interviewStartDatetime: startDateTime.date, interviewEndDatetime: endDateTime.date, interviewVideoLink: vidLink , interviewLocation: interviewLocation, interviewNotifDatetime: notifDatePicker.date, interviewNotes: notes)
        
        // schedule local notification
        scheduleStartDateTimeNotification()
        scheduleNotifDateTimeNotification()
        
        navigationController?.popViewController(animated: true)
    }
    
    func scheduleStartDateTimeNotification() {
        // set a simple notification
        // check that notifications were enabled
        guard appDelegate.notificationsEnabled else {
            print("Notifications not enabled")
            return
        }
        
        // set notification for interview start date time =================================
        let content = UNMutableNotificationContent()
        content.title = "Interview Reminder"
        content.body = "Your interview starts now."
        content.sound = UNNotificationSound.default

        let interviewStartDatetime = startDateTime.date
        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: interviewStartDatetime)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)

        // create a request
        let request = UNNotificationRequest(identifier: AppDelegate.INTERVIEW_STARTTIME_NOTIF_IDENTIFIER, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling (interviewStartDatetime) notification: \(error)")
            } else {
                print("interviewStartDatetime Notification scheduled.")
            }
        }
    }
    
    func scheduleNotifDateTimeNotification() {
        // check that notifications were enabled
        guard appDelegate.notificationsEnabled else {
            print("Notifications not enabled")
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = "Interview Reminder"
        content.body = "Your interview starts soon."
        content.sound = UNNotificationSound.default

        let selectedNotifDatetime = notifDatePicker.date
        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: selectedNotifDatetime)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)

        // create a request
        let request = UNNotificationRequest(identifier: AppDelegate.INTERVIEW_REMINDER_NOTIF_IDENTIFIER, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling (NotifDatetime) notification: \(error)")
            } else {
                print("NotifDatetime Notification scheduled.")
            }
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
