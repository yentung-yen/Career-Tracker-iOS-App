//
//  ApplicationTrackerViewController.swift
//  fit3178_majorAssignment
//
//  Created by Chin Yen Tung on 1/5/2024.
//

import UIKit

class ApplicationTrackerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var screenLabel: UILabel!
    
    // Constants for Table
    let SECTION_APPLICATION = 0
    let SECTION_INFO = 1
    
    let CELL_APPLICATION = "applicationCell"
    let CELL_INFO = "totalCell"
    
    // array to hold the applications we want to display
    var displayApplication: [ApplicationDetails] = []
    var allApplications: [ApplicationDetails] = []
    
    weak var applicationDelegate: AddApplicationDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //TODO: remove after implementing coredata
        allApplications.append(ApplicationDetails(jobTitle: "jobTitle", company: "company", jobLocation: "jobLocation",
                                                  jobMode: .Hybrid, salary: 25245, postURL: "jobPostURL",
                                                  applicationStatus: .Applied, notes: "notes"))
        allApplications.append(ApplicationDetails(jobTitle: "jobTitle 2", company: "company", jobLocation: "jobLocation",
                                                  jobMode: .InPerson, salary: 437347, postURL: "jobPostURL",
                                                  applicationStatus: .Interview, notes: "notes"))
        allApplications.append(ApplicationDetails(jobTitle: "jobTitle 3", company: "company", jobLocation: "jobLocation",
                                                  jobMode: .Online, salary: 7869, postURL: "jobPostURL",
                                                  applicationStatus: .OA, notes: "notes"))
        allApplications.append(ApplicationDetails(jobTitle: "jobTitle 4", company: "company", jobLocation: "jobLocation",
                                                  jobMode: .Hybrid, salary: 262785, postURL: "jobPostURL",
                                                  applicationStatus: .Offered, notes: "notes"))

        // Do any additional setup after loading the view.
        tableView.dataSource = self
        tableView.delegate = self
        screenLabel.text = "Applied"
        displayApplication = allApplications.filter { $0.applicationStatus == .Applied }  // only show Applied data at start
        print(displayApplication.count)
    }
    
    @IBAction func onToggleApplicationStatusSegment(_ sender: UISegmentedControl) {
        let selectedToggle = sender.selectedSegmentIndex // get toggle segment number
        
        if selectedToggle == 0 {
            displayApplication = allApplications.filter { $0.applicationStatus == .Applied }
            screenLabel.text = "Applied"
        } else if selectedToggle == 1 {
            displayApplication = allApplications.filter { $0.applicationStatus == .OA }
            screenLabel.text = "Online Assessment"
        } else if selectedToggle == 2 {
            displayApplication = allApplications.filter { $0.applicationStatus == .Interview }
            screenLabel.text = "Interview"
        } else if selectedToggle == 3 {
            displayApplication = allApplications.filter { $0.applicationStatus == .Offered }
            screenLabel.text = "Offered"
        }
        tableView.reloadData()
    }
    
    
    // MARK: - Table Controllers
    
    // determines the number of sections in the Table View
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    // We refer to this method as “tableViewNumberOfRowsInSection"
    // determines the number of rows in a specified section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
            case SECTION_APPLICATION:
                return displayApplication.count
                
            case SECTION_INFO:
                return 1
                
            default:
                return 0
        }
    }
    
    // creates the cells to be displayed to the user
    // calls the dequeReusableCell method and provide it an identifier - identifier must match a Reuse Identifier we created on the storyboard
    // calls indexPath to generate a cell object - index path specifies a section and row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == SECTION_APPLICATION {
            // Configure and return a application cell
            let applicationCell = tableView.dequeueReusableCell(withIdentifier: CELL_APPLICATION, for: indexPath)
            
            // set their content using the appropriate application details
            var content = applicationCell.defaultContentConfiguration()
            // indexPath contains the current row number which will correspond to a specific application in our array
            // because we’ve told the table view that the number of rows in this section = array length.
            let application = displayApplication[indexPath.row]
            
            content.text = application.jobTitle
            content.secondaryText = application.company
            applicationCell.contentConfiguration = content
            
            return applicationCell     // return a cell object
            
        } else {
            // Unlike the previous Table View, we are using a custom cell type we created ourselves
            // So we need to dequeue the cell and cast it to its correct type (in order to use the totalLabel property)
            
            // forced cast is done using the as! Keyword, specifying the class we want to cast to
            // If a forced cast fails the app will immediately crash.
            // Forced cast should only be done when we know 100% that the cell (or other type) we are casting is a particular type
            let infoCell = tableView.dequeueReusableCell(withIdentifier: CELL_INFO, for: indexPath) as! ApplicationCountTableViewCell
            infoCell.totalLabel?.text = "Total Applications: \(displayApplication.count)"
            
            return infoCell
        }
    }
    

    // allows us to specify whether a certain row can be edited by the user (update, delete).
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Check the section of the indexPath
        if indexPath.section == SECTION_APPLICATION {
            return true // Allow editing
        } else {
            // Info Cells section
            return false // Dont allow editing
        }
    }
    
    // handles deletion or insertion of rows into our table view
    // method provides an index path for a specified section and row
    // method also provides an editing style
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        // editingStyle == .delete implicitly enables the swipe-to-delete feature
        // In iOS, the default swipe gesture for deletion in a UITableView is from right to left to ensure consistency
        if editingStyle == .delete && indexPath.section == SECTION_APPLICATION {
            // performBatchUpdates allows us to provide a closure to execute in a single batch.
            // necessary when multiple changes to a table view/ collection view is needed at once
            tableView.performBatchUpdates({
                self.allApplications.remove(at: indexPath.row) // remove hero from current party
                self.tableView.deleteRows(at: [indexPath], with: .fade) // delete that row from table view
                self.tableView.reloadSections([SECTION_INFO], with: .automatic) // update info section
            }, completion: nil)
            
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
