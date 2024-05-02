//
//  AllJournalEntryTableViewController.swift
//  jobApplication_prepTrack_app
//
//  Created by Chin Yen Tung on 2/5/2024.
//

import UIKit

class AllJournalEntryTableViewController: UITableViewController, UISearchResultsUpdating, DatabaseListener {
    let SECTION_JOURNAL_ENTRIES = 0
    let SECTION_ENTRIES_COUNT = 1
    
    let CELL_JOURNAL_ENTRY = "journalEntryCell"
    let CELL_ENTRIES_COUNT = "journalEntryTotalCell"
    
    var allJournalEntries: [JournalEntry] = []
    var filteredJournalEntries: [JournalEntry] = []
    
    var listenerType = ListenerType.journalEntry    // specify the listener type this class will be.
    weak var databaseController: DatabaseProtocol?  // hold a reference to the database

    override func viewDidLoad() {
        super.viewDidLoad()

        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        filteredJournalEntries = allJournalEntries
        
        // create UISeachController and assign it to the View Controller
        let searchController = UISearchController(searchResultsController: nil)
        
        // indicates that the current object (self - which is the AllHeroesTableViewController) will handle updates to the search results
        // enable the object containing it to receive updates to search results entered by the user in a UISearchController
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Journal Entry"        // set search bar placeholder text
        
        // tell our navigationItem that its search controller is the one we just created above
        // this adds the search bar to the view controller
        navigationItem.searchController = searchController
        
        // This view controller decides how the search controller is presented
        definesPresentationContext = true
        // ==============================================================
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
        // do nothing
    }
    
    func onAllJournalEntryChange(change: DatabaseChange, journalEntry: [JournalEntry]) {
        allJournalEntries = journalEntry      // update our full hero list
        updateSearchResults(for: navigationItem.searchController!)  // update filtered list based on search results
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
            filteredJournalEntries = allJournalEntries.filter({ (entry: JournalEntry) -> Bool in
                // use nil-coalescing operator (??) since name property is optional
                return (entry.journalEntryTitle?.lowercased().contains(searchText) ?? false)
            })
        } else {
            filteredJournalEntries = allJournalEntries
        }
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
            case SECTION_JOURNAL_ENTRIES:
                return filteredJournalEntries.count
                
            case SECTION_ENTRIES_COUNT:
                return 1
                
            default:
                return 0
        }
    }

    // creates the cells to be displayed to the user
    // calls the dequeReusableCell method and provide it an identifier - identifier must match a Reuse Identifier we created on the storyboard
    // calls indexPath to generate a cell object - index path specifies a section and row
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == SECTION_JOURNAL_ENTRIES {
            // Configure and return a cell
            let entryCell = tableView.dequeueReusableCell(withIdentifier: CELL_JOURNAL_ENTRY, for: indexPath)
            
            // set their content using the appropriate details
            var content = entryCell.defaultContentConfiguration()
            // indexPath contains the current row number which will correspond to a specific application in our array
            // because we’ve told the table view that the number of rows in this section = array length.
            let entry = filteredJournalEntries[indexPath.row]
            
            content.text = entry.journalEntryTitle
            content.secondaryText = entry.journalEntryDate
            entryCell.contentConfiguration = content
            
            return entryCell     // return a cell object
            
        } else {
            // Unlike the previous Table View, we are using a custom cell type we created ourselves
            // So we need to dequeue the cell and cast it to its correct type (in order to use the totalLabel property)
            
            // forced cast is done using the as! Keyword, specifying the class we want to cast to
            // If a forced cast fails the app will immediately crash.
            // Forced cast should only be done when we know 100% that the cell (or other type) we are casting is a particular type
            let infoCell = tableView.dequeueReusableCell(withIdentifier: CELL_ENTRIES_COUNT, for: indexPath)
            
            var content = infoCell.defaultContentConfiguration()
            content.text = "Total Entries: \(allJournalEntries.count)"
            infoCell.contentConfiguration = content
            
            return infoCell
        }
    }
    
    // allows us to specify whether a certain row can be edited by the user (update, delete).
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Check the section of the indexPath
        if indexPath.section == SECTION_JOURNAL_ENTRIES {
            return true // Allow editing
        } else {
            // Info Cells section
            return false // Dont allow editing
        }
    }

    // handles deletion or insertion of rows into our table view
    // method provides an index path for a specified section and row
    // method also provides an editing style
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        // editingStyle == .delete implicitly enables the swipe-to-delete feature
        // In iOS, the default swipe gesture for deletion in a UITableView is from right to left to ensure consistency
        if editingStyle == .delete && indexPath.section == SECTION_JOURNAL_ENTRIES {
            let entry = filteredJournalEntries[indexPath.row]
            databaseController?.deleteJournalEntry(journalEntry: entry)
        }
    }

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
        if segue.identifier == "viewJournalEntrySegue" {
            if let indexPath = tableView.indexPathForSelectedRow{
                if let destinationVC = segue.destination as? ViewJournalEntryViewController {
                    destinationVC.currentJournalEntry = filteredJournalEntries[indexPath.row]
                    print(filteredJournalEntries[indexPath.row])
                }
            }
        }
    }
    

}
