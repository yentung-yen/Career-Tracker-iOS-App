//
//  InterviewScheduleCollectionViewController.swift
//  jobApplication_prepTrack_app
//
//  Created by Chin Yen Tung on 16/5/2024.
//

import UIKit

class InterviewScheduleCollectionViewController: UICollectionViewController {
    let DAY_HEADER_SECTION = 0
    let DATES_SECTION = 1
    
    let CALENDAR_CELL = "calendarCell"
    
    // for setting dates in calendar
    var dates: [Int] = []
    var currentDate = Date()
    let calendar = Calendar.current // get user's current calendar settings
    
    // for setting day headers in calendar
    var dayHeaderList: [String] = []
    let daysOfWeek = ["S", "M", "T", "W", "T", "F", "S"]
    var userFirstWeekday = 0
    var calendarStartDayIndex = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
//        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
        getNumOfCellsInCalendarMonth()
        getCalendarHeader()
        
        // conform to UICollectionViewDelegate and UICollectionViewDataSource protocols
        collectionView.dataSource = self
        collectionView.delegate = self
        
        // set collection view layout
        collectionView.setCollectionViewLayout(setSectionLayout(), animated: false)
    }
    
    func getNumOfCellsInCalendarMonth() {
        var numDays = 0

//        var components = DateComponents()
//        components.year = 2023
//        components.month = 1
//        components.day = 10
//        currentDate = calendar.date(from: components) ?? Date()

        // get number of days in a month (need guard because it returns optional and can be nil)
        guard let range = calendar.range(of: .day, in: .month, for: currentDate) else { return }
        numDays = range.count

        // create new date object and set month and year to currentDate's month and yeaar
        let newDate = calendar.dateComponents([.year, .month], from: currentDate)
        // since "day" wasnt set, date(from:) will default to get first day of the month
        guard let firstDateOfMonth = calendar.date(from: newDate) else { return }
        // get the day for the 1st of each month
        let firstDayOfMonth = calendar.component(.weekday, from: firstDateOfMonth)

        // get user's first day of the week (some countries start with Monday, some with Sunday, etc)
        // returns a number representing the day (Sunday = 1, Monday = 2, etc)
        userFirstWeekday = calendar.firstWeekday
        // get the position the 1st date should be in the calender which corresponds to the day of the 1st date of each month
        // (e.g. If week starts on Monday; 2=Wed, 0=Mon)
        calendarStartDayIndex = (firstDayOfMonth - userFirstWeekday + 7) % 7

        // if the first day on the month isn't the first day of the week
        if calendarStartDayIndex > 0 {
            // prefill the front with 100 just so we start on the right index when creating the calendar
            for _ in 0..<calendarStartDayIndex {
                dates.append(100)
            }
        }
        
        // for i in range(1,numDays+1)
        for i in 1..<numDays + 1 {
            dates.append(i)
        }
    }
    
    func getCalendarHeader() {
        let index = userFirstWeekday - 1  // convert to zero-based index
        
        // list slicing - slice daysOfWeek list based on index (which is based on userFirstWeekday)
        dayHeaderList = Array(daysOfWeek[index...] + daysOfWeek[..<index])
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
        return 2
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var numOfCells = 0
        
        if section == DAY_HEADER_SECTION {
            numOfCells = 7
        } else if section == DATES_SECTION {
            numOfCells = dates.count
        }
        return numOfCells
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CALENDAR_CELL, for: indexPath) as! InterviewScheduleCollectionViewCell
        
        // Configure the cell
        if indexPath.section == 0 {
            let day = dayHeaderList[indexPath.item]
            cell.dateLabel.text = day
            
            //TODO: remove
            cell.backgroundColor = UIColor.systemGray3
            
        } else if indexPath.section == 1 {
            let date = dates[indexPath.item]
            
            // front of dates list is prefilled with 100 just so we start on the right index when creating the calendar
            // so if the date is 100, just show an empty string on the label
            if date == 100 {
                cell.dateLabel.text = ""
            } else {
                cell.dateLabel.text = String(date)
            }
            
            //TODO: remove
            cell.backgroundColor = UIColor.systemBlue
        }
        return cell
    }
    
    
    // MARK: Collection View Layout
    
    func setSectionLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { [self] (section, enviroment) in
            if section == DAY_HEADER_SECTION {
                return calendarHeaderSectionLayout()
            }
            else if section == DATES_SECTION {
                return calendarDatesSectionLayout()
            }
            else {
                return calendarHeaderSectionLayout()
            }
        }
    }
    
    func calendarHeaderSectionLayout() -> NSCollectionLayoutSection {
        // Tiled layout
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/7), heightDimension: .fractionalHeight(1))
        let itemLayout = NSCollectionLayoutItem(layoutSize: itemSize)
        // Add padding around each item
        itemLayout.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 3, bottom: 0, trailing: 3)
        
        // set fixed height
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(30))
        let layoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [itemLayout])
        
        let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
        layoutSection.contentInsets = NSDirectionalEdgeInsets(top: 15, leading: 15, bottom: 10, trailing: 15)
        
        return layoutSection
    }
        
    func calendarDatesSectionLayout() -> NSCollectionLayoutSection {
        // Tiled layout
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/7), heightDimension: .fractionalHeight(1))
        let itemLayout = NSCollectionLayoutItem(layoutSize: itemSize)
        // Add padding around each item
        itemLayout.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 3, bottom: 0, trailing: 3)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1/9))
        let layoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [itemLayout])
        
        let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
        layoutSection.interGroupSpacing = 5
        layoutSection.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 15, bottom: 15, trailing: 15)
        
        return layoutSection
    }
    
    // To set section header title
//    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
//
//        let year = 2024 - indexPath.section
//
//        if let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "headerView", for: indexPath) as? HeaderCollectionReusableView {
//            sectionHeader.labelTextView.text = String(year)
//            return sectionHeader
//        }
//        return UICollectionReusableView()
//    }


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
