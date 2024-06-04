//
//  AllJournalEntryTableViewController.swift
//  jobApplication_prepTrack_app
//
//  Created by Chin Yen Tung on 2/5/2024.
//

import UIKit

// conform to UISearchResultsUpdating to allow search functionality to update table view (updateSearchResults() delegate method)
// conform to UISearchControllerDelegate to allow us to use the didDismissSearchController() delegate method
class AllJournalEntryTableViewController: UITableViewController, UISearchResultsUpdating, UISearchControllerDelegate, DatabaseListener {
    // to show journal entries according to categories
    var hideDuplicate = false
    var userCategoryList: [String] = []
    var isCategoryTitleCell = true
    var currentCategoryItems: [JournalEntry] = []
    var currentCategoryIndex: Int = 0
    var currentCatItemIdx: Int = 0
    var numOfEntriesToShow: Int = 0
    
    let SECTION_JOURNAL_ENTRIES = 0
    let SECTION_ENTRIES_COUNT = 1
    
    let CELL_JOURNAL_ENTRY = "journalEntryCell"
    let CELL_ENTRIES_COUNT = "journalEntryTotalCell"
    
    var allJournalEntries: [JournalEntry] = []
    var filteredJournalEntries: [JournalEntry] = []
    
    var listenerType = ListenerType.journalEntry    // specify the listener type this class will be.
    weak var databaseController: DatabaseProtocol?  // hold a reference to the database
    
    // so that we have a reference to the searchController throughout the view/screen
    var searchController: UISearchController?

    override func viewDidLoad() {
        super.viewDidLoad()

        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.firebaseDatabaseController
        
        // get this user's list of categories
//        updateFilteredUserCategoryList()
        
        // create UISeachController and assign it to the View Controller
        searchController = UISearchController(searchResultsController: nil)
        
        // indicates that the current object (self - which is the AllHeroesTableViewController) will handle updates to the search results
        // enable the object containing it to receive updates to search results entered by the user in a UISearchController
        searchController?.searchResultsUpdater = self
        searchController?.obscuresBackgroundDuringPresentation = false
        searchController?.searchBar.placeholder = "Search Journal Entry"        // set search bar placeholder text
        searchController?.delegate = self
        
        // This view controller decides how the search controller is presented
        definesPresentationContext = true
        // ==============================================================
    }
    
    // method 1: viewWillAppear - This method is called before the view appears on screen.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self) // In this method, we add ourselves to the database listeners
        updateFilteredUserCategoryList()
    }
    // method 2: viewWillDisappear
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)  // remove ourlseves from the database listener
    }
    // With these two methods, the View Controller will:
    // - automatically register itself to receive updates from the database when the view is about to appear on screen and
    // - deregister itself when it’s about to disappear.
    
    func onAllApplicationDetailsChange(change: DatabaseChange, applicationDetails: [ApplicationDetail]) {
        // do nothing
    }
    
    func onAllInterviewScheduleChange(change: DatabaseChange, interviewScheduleDetail: [InterviewScheduleDetail]) {
        // do nothing
    }
    
    func onAllJournalEntryChange(change: DatabaseChange, journalEntry: [JournalEntry]) {
        allJournalEntries = journalEntry      // update our full journal list
        filteredJournalEntries = allJournalEntries  // start with all journal entries on loading the view
        tableView.reloadData()
        
        // searchController might be nil, so safely unwrap it
        if let searchController = navigationItem.searchController {
            updateSearchResults(for: searchController)  // update filtered list based on search results
        }
    }
    
    // MARK: Search bar functions
    
    // this function is called when the user taps on the search icon
    @IBAction func onClickSearchIcon(_ sender: Any) {
        // present searchController when the icon is tapped
        if let searchController = searchController {
            // add padding to top of the table view so that the search controller doesnt block it
            tableView.contentInset = UIEdgeInsets(top: 40, left: 0, bottom: 0, right: 0)
            present(searchController, animated: true, completion: nil)
        }
    }
    
    // this function is called when the search controller is dismissed
    func didDismissSearchController(_ searchController: UISearchController) {
        // reset content inset when search controller is dismissed
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
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
                return (entry.entryTitle?.lowercased().contains(searchText) ?? false)
            })
            countNumOfEntriesToShow()   // get new number of entries to show after filter
            updateFilteredUserCategoryList()  // get new list of categories to show
        } else {
            filteredJournalEntries = allJournalEntries
            countNumOfEntriesToShow()
            updateFilteredUserCategoryList()
        }
        tableView.reloadData()
    }

    
    // MARK: methods related to showing duplicate journal entries view
    
    // this function counts the number of rows the table should show for journal entries accounting for duplicate entries
    func countNumOfEntriesToShow() {
        var numOfEntriesToShow = 0
        
        for entry in filteredJournalEntries {
            let numOfCat = entry.entryCategories?.count
            numOfEntriesToShow += numOfCat!
        }
        self.numOfEntriesToShow = numOfEntriesToShow
    }
    
    func updateFilteredUserCategoryList() {
        var currentCategories: [String] = []
        
        for entry in filteredJournalEntries {
            let catArray = entry.entryCategories
            
            for cat in catArray! {
                if !currentCategories.contains(cat) {
                    currentCategories.append(cat)
                }
            }
        }
        self.userCategoryList = currentCategories
        print(self.userCategoryList)
    }
    
    @IBAction func onToggleDuplicateEntryView(_ sender: Any) {
        self.hideDuplicate = !self.hideDuplicate
        print(self.hideDuplicate)
        
        // reset
//        self.isCategoryTitleCell = true
//        self.currentCategoryItems = []
//        self.currentCategoryIndex = 0
//        self.currentCatItemIdx = 0
//        self.numOfEntriesToShow = 0
        
        tableView.reloadData()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == SECTION_JOURNAL_ENTRIES {
            if hideDuplicate == true {
                return filteredJournalEntries.count
                
            } else if hideDuplicate == false {
                return filteredJournalEntries.count + userCategoryList.count
            }
        } else if section == SECTION_ENTRIES_COUNT {
            return 1
        }
        return 0
    }

    // creates the cells to be displayed to the user
    // calls the dequeReusableCell method and provide it an identifier - identifier must match a Reuse Identifier we created on the storyboard
    // calls indexPath to generate a cell object - index path specifies a section and row
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.hideDuplicate == true {
            if indexPath.section == SECTION_JOURNAL_ENTRIES {
                // Configure and return a cell
                let entryCell = tableView.dequeueReusableCell(withIdentifier: CELL_JOURNAL_ENTRY, for: indexPath)
                entryCell.backgroundColor = UIColor.lightGray
                
                // set their content using the appropriate details
                var content = entryCell.defaultContentConfiguration()
                // indexPath contains the current row number which will correspond to a specific application in our array
                // because we’ve told the table view that the number of rows in this section = array length.
                let entry = filteredJournalEntries[indexPath.row]
                
                content.text = entry.entryTitle
                content.secondaryText = entry.entryDate
                entryCell.contentConfiguration = content
                
                return entryCell     // return a cell object
                
            } else {
                let infoCell = tableView.dequeueReusableCell(withIdentifier: CELL_ENTRIES_COUNT, for: indexPath)
                
                var content = infoCell.defaultContentConfiguration()
                content.text = "Total Entries: \(filteredJournalEntries.count)"
                infoCell.contentConfiguration = content
                
                return infoCell
            }
        } else if self.hideDuplicate == false {
            if indexPath.section == SECTION_JOURNAL_ENTRIES {
                // set up current category item list
                if self.currentCategoryItems.count == 0 {
                    // if we haven't get all the entries for this category yet, get it
                    self.currentCategoryItems = filteredJournalEntries.filter { entry in
                        entry.entryCategories!.contains(self.userCategoryList[self.currentCategoryIndex])
                    }
                }
                
                // create category title cells
                if self.isCategoryTitleCell == true {
                    // Configure and return a cell
                    let entryCell = tableView.dequeueReusableCell(withIdentifier: CELL_JOURNAL_ENTRY, for: indexPath)
                    
                    // set their content using the appropriate details
                    var content = entryCell.defaultContentConfiguration()
                    
                    content.text = self.userCategoryList[self.currentCategoryIndex]
                    content.secondaryText = "Total Entries: \(self.currentCategoryItems.count)"
                    entryCell.contentConfiguration = content
                    self.isCategoryTitleCell = false
                    
                    return entryCell     // return a cell object
                    
                } else if self.isCategoryTitleCell == false {
                    // Configure and return a cell
                    let entryCell = tableView.dequeueReusableCell(withIdentifier: CELL_JOURNAL_ENTRY, for: indexPath)
                    entryCell.backgroundColor = UIColor.lightGray
                    
                    // set their content using the appropriate details
                    var content = entryCell.defaultContentConfiguration()
                    
                    let entry = self.currentCategoryItems[self.currentCatItemIdx]
                    
                    content.text = entry.entryTitle
                    content.secondaryText = entry.entryDate
                    entryCell.contentConfiguration = content
                    
                    // if it's the last item in that category
                    if self.currentCatItemIdx == self.currentCategoryItems.count - 1 {
                        // reset
                        self.isCategoryTitleCell = true
                        self.currentCategoryItems = []
                        self.currentCategoryIndex += 1   // increment catIdx to reference to next category
                        self.currentCatItemIdx = 0
                    } else {
                        self.currentCatItemIdx += 1
                    }
                    
                    // if it's the last category
                    if self.currentCategoryIndex == self.userCategoryList.count - 1 {
                        self.currentCategoryIndex = 0    // reset catIdx to 0
                    }
                    
                    return entryCell     // return a cell object
                }
            } else {
                let infoCell = tableView.dequeueReusableCell(withIdentifier: CELL_ENTRIES_COUNT, for: indexPath)
                
                var content = infoCell.defaultContentConfiguration()
                content.text = "Total Entries: \(filteredJournalEntries.count)"
                infoCell.contentConfiguration = content
                
                return infoCell
            }
        }
        // Configure and return a cell
        let entryCell = tableView.dequeueReusableCell(withIdentifier: CELL_JOURNAL_ENTRY, for: indexPath)
        return entryCell     // return a cell object
    }
    
    // TODO: allows us to specify whether a certain row can be edited by the user (update, delete).
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
//                    print(filteredJournalEntries[indexPath.row])
                }
            }
        }
    }
    

}
