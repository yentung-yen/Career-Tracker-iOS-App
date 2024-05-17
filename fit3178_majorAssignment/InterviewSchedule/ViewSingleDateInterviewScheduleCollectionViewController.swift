//
//  ViewSingleDateInterviewScheduleCollectionViewController.swift
//  jobApplication_prepTrack_app
//
//  Created by Chin Yen Tung on 17/5/2024.
//

import UIKit

class ViewSingleDateInterviewScheduleCollectionViewController: UICollectionViewController, DatabaseListener {
    let INTERVIEW_CELL = "interviewCell"
    var allinterviewList = [InterviewScheduleDetail]() // to list all interviews
    var displayinterviewList = [InterviewScheduleDetail]() // to only show interviews for that date
    
    var selectedDate: Int?
    var selectedMonth: Int?
    var selectedYear: Int?
    
    var listenerType = ListenerType.interviewSchedule
    weak var databaseController: DatabaseProtocol?
    
    // to filter for interviews in this date only
    let calendar = Calendar.current

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // code to set the databaseController
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.firebaseDatabaseController

        // conform to UICollectionViewDelegate and UICollectionViewDataSource protocols
        collectionView.dataSource = self
        collectionView.delegate = self
        
        // set collection view layout
        collectionView.setCollectionViewLayout(UICollectionViewCompositionalLayout(section: createTiledLayoutSection()), animated: false)
    }
    
    // MARK: - Database Controller
    
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
    
    func onAllJournalEntryChange(change: DatabaseChange, journalEntry: [JournalEntry]) {
        // do nothing
    }
    
    func onAllApplicationDetailsChange(change: DatabaseChange, applicationDetails: [ApplicationDetail]) {
        // do nothing
    }
    
    func onAllInterviewScheduleChange(change: DatabaseChange, interviewScheduleDetail: [InterviewScheduleDetail]) {
        allinterviewList = interviewScheduleDetail
        
        // only show interviews for that specific date
        var dateComponents = DateComponents()   // construct date object
        dateComponents.year = selectedYear
        dateComponents.month = selectedMonth
        dateComponents.day = selectedDate
        
        // construct date object from dateComponents
        if let selectedDate = calendar.date(from: dateComponents) {
//            print("selected date: \(selectedDate)")
            
            // filter
            displayinterviewList = allinterviewList.filter { interview in
                if let startDate = interview.interviewStartDatetime {
                    
//                    let startDateString = DateFormatter.localizedString(from: startDate, dateStyle: .medium, timeStyle: .none)
//                    let targetDateString = DateFormatter.localizedString(from: selectedDate, dateStyle: .medium, timeStyle: .none)
//                    print("Comparing \(startDateString) to \(targetDateString)")
                    
                    // We use a calendar to compare only the date components (year, month, day) ignoring time of day
                    return calendar.isDate(startDate, inSameDayAs: selectedDate)
                }
                return false
            }
        }
        
//        print("all interviews list count:")
//        print(allinterviewList.count)
//        print("display interviews list count:")
//        print(displayinterviewList.count)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if displayinterviewList.count == 0 {
            return 1
        }
        return displayinterviewList.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: INTERVIEW_CELL, for: indexPath) as! ViewSingleDateInterviewScheduleCollectionViewCell
        
        if displayinterviewList.count == 0 {
            cell.titleLabel.text = "No interviews on this date :)"
            
        } else {
            let title = displayinterviewList[indexPath.item].interviewTitle
            let startDateTime = displayinterviewList[indexPath.item].interviewStartDatetime
            let endDateTime = displayinterviewList[indexPath.item].interviewEndDatetime
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd-MMM-yyy HH:mm"
            
            cell.backgroundColor = UIColor.systemGray3
            cell.titleLabel.text = title
            cell.startDatetimeLabel.text = dateFormatter.string(from: startDateTime!)
            cell.endDatetimeLabel.text = dateFormatter.string(from: endDateTime!)
        }
        
        return cell
    }
    
    
    // MARK: Collection View Layout
    
    func createTiledLayoutSection() -> NSCollectionLayoutSection {
        // Tiled layout.
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let itemLayout = NSCollectionLayoutItem(layoutSize: itemSize)
        // Add padding around each item
        itemLayout.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 2, bottom: 0, trailing: 2)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(1/3))
        let layoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [itemLayout])
        
        let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
        layoutSection.interGroupSpacing = 5
        layoutSection.contentInsets = NSDirectionalEdgeInsets(top: 15, leading: 25, bottom: 15, trailing: 25)
        
        //layoutSection.orthogonalScrollingBehavior = .continuous
        return layoutSection
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
