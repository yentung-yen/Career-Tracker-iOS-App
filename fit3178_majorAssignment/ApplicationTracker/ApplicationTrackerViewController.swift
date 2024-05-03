//
//  ApplicationTrackerViewController.swift
//  fit3178_majorAssignment
//
//  Created by Chin Yen Tung on 1/5/2024.
//

import UIKit

class ApplicationTrackerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating, DatabaseListener {
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
    var filteredApplications: [ApplicationDetails] = []
    var selectedToggle: Int = 0
    
    var searchController: UISearchController!
    
    var listenerType = ListenerType.applicationDetails
    weak var databaseController: DatabaseProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // code to set the databaseController
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        tableView.dataSource = self
        tableView.delegate = self
        screenLabel.text = "Applied"
        
        // search controller =================================
        // only show Applied data at start
        displayApplication = allApplications.filter { $0.applicationApplicationStatus == .Applied }
        
        // create UISeachController and assign it to the View Controller
        searchController = UISearchController(searchResultsController: nil)
        
        // indicates that the current object (self - which is the AllHeroesTableViewController) will handle updates to the search results
        // enable the object containing it to receive updates to search results entered by the user in a UISearchController
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Applications" // set search bar placeholder text
        
        // tell our navigationItem that its search controller is the one we just created above
        // this adds the search bar to the view controller
        navigationItem.searchController = searchController
        
        // This view controller decides how the search controller is presented
        definesPresentationContext = true
        // ===================================================
    }
    
    @IBAction func onToggleApplicationStatusSegment(_ sender: UISegmentedControl) {
        selectedToggle = sender.selectedSegmentIndex // get toggle segment number
        
        if selectedToggle == 0 {
            displayApplication = allApplications.filter { $0.applicationApplicationStatus == .Applied }
            screenLabel.text = "Applied"
        } else if selectedToggle == 1 {
            displayApplication = allApplications.filter { $0.applicationApplicationStatus == .OA }
            screenLabel.text = "Online Assessment"
        } else if selectedToggle == 2 {
            displayApplication = allApplications.filter { $0.applicationApplicationStatus == .Interview }
            screenLabel.text = "Interview"
        } else if selectedToggle == 3 {
            displayApplication = allApplications.filter { $0.applicationApplicationStatus == .Offered }
            screenLabel.text = "Offered"
        }
        tableView.reloadData()
    }
    
    // method 1: viewWillAppear - This method is called before the view appears on screen.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self) // In this method, we add ourselves to the database listeners
    }
    // method 2: viewWillDisappear
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)  // remove ourlseves from the database listener
    }
    // With these two methods, the View Controller will:
    // - automatically register itself to receive updates from the database when the view is about to appear on screen and
    // - deregister itself when it’s about to disappear.
    
    func onAllApplicationDetailsChange(change: DatabaseChange, applicationDetails: [ApplicationDetails]) {
        allApplications = applicationDetails
        print(allApplications.count)
        updateSearchResults(for: navigationItem.searchController!)
    }
    
    // This method is called every time a change is detected in the search bar
    func updateSearchResults(for searchController: UISearchController) {
        
        // check to ensure that there is search text we can access before starting any filtering
        // search text converted to lowercase so that we dont need to worry about case sensitivity
        guard let searchText = searchController.searchBar.text?.lowercased() else {
            return
        }
        
        // check is to see if there is a search term by checking if string length is > 0
        if searchText.count > 0 {
            // if there is a search text, filter
            // we are including a row into our filtered list if it contains the search text
            filteredApplications = displayApplication.filter({ (application: ApplicationDetails) -> Bool in
                // use nil-coalescing operator (??) since name property is optional
                return (application.jobTitle?.lowercased().contains(searchText) ?? false)
            })
            displayApplication = filteredApplications
        } else {
            if selectedToggle == 0 {
                displayApplication = allApplications.filter { $0.applicationApplicationStatus == .Applied }
                
            } else if selectedToggle == 1 {
                displayApplication = allApplications.filter { $0.applicationApplicationStatus == .OA }
                
            } else if selectedToggle == 2 {
                displayApplication = allApplications.filter { $0.applicationApplicationStatus == .Interview }
                
            } else if selectedToggle == 3 {
                displayApplication = allApplications.filter { $0.applicationApplicationStatus == .Offered }
            }
        }
        tableView.reloadData()
    }
    
    func onAllJournalEntryChange(change: DatabaseChange, journalEntry: [JournalEntry]) {
        // do nothing
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
            let application = displayApplication[indexPath.row]
            databaseController?.deleteApplication(applicationDetails: application)
            
        }
    }
    
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "viewAndEditApplicationSegue" {
            if let indexPath = tableView.indexPathForSelectedRow{
                if let destinationVC = segue.destination as? ViewApplicationDetailsViewController {
                    destinationVC.currentApplicationDetails = displayApplication[indexPath.row]
                    print(displayApplication[indexPath.row])
                }
            }
        }
    }
    

}
