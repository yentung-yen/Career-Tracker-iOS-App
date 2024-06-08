//
//  InterviewScheduleCollectionViewController.swift
//  jobApplication_prepTrack_app
//
//  Created by Chin Yen Tung on 16/5/2024.
//

import UIKit

class InterviewScheduleCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    let DAY_HEADER_SECTION = 0
    let DATES_SECTION = 1
    
    let CALENDAR_CELL = "calendarCell"
    let dateFormatter = DateFormatter()
    
    // for setting dates in calendar
    var dates: [Int] = []
    var calendar = Calendar.current // get user's current calendar settings
    var currentDate = Date()
    var todayDate = Date()
    var todayDay: Int = 0
    var todayYear: Int = 0
    var todayMonth: Int = 0
    
    // for setting day headers in calendar
    var dayHeaderList: [String] = []
    let daysOfWeek = ["S", "M", "T", "W", "T", "F", "S"]
    var userFirstWeekday = 0
    var calendarStartDayIndex = 0
    
    // to store current year and month to pass over to other screens
    var currentYearShown: Int?
    var currentMonthShown: Int?
    
    // store index of previously selected cell
    var lastSelectedCell: IndexPath?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
//        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
        getNumOfCellsInCalendarMonth()
        getCalendarHeader()
        
        // set current year and month
        todayDate = Date()
        calendar = Calendar.current
        currentYearShown = calendar.component(.year, from: todayDate)
        currentMonthShown = calendar.component(.month, from: todayDate)
//        print(currentYearShown!)
//        print(currentMonthShown!)
        
        // set last selected cell to default to today's date
        todayDay = calendar.component(.day, from: todayDate)
        lastSelectedCell = [DATES_SECTION, todayDay]
//        print(todayDay)
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        // set collection view layout
        collectionView.setCollectionViewLayout(setSectionLayout(), animated: false)
    }
    
    func getNumOfCellsInCalendarMonth() {
        var numDays = 0

        // create date object based on current year and month user has moved to
        var components = DateComponents()
        components.year = currentYearShown
        components.month = currentMonthShown
        components.day = 1
        currentDate = calendar.date(from: components)!
        
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

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        if segue.identifier == "createInterviewScheduleSegue" {
            if let destinationVC = segue.destination as? AddInterviewViewController {
                var date = 0
                
                // if no date is selected, send today's date over
                if lastSelectedCell == nil {
                    date = todayDay
                    destinationVC.selectedDate = date
                    destinationVC.selectedMonth = todayMonth
                    destinationVC.selectedYear = todayYear
                } else {
                    date = dates[lastSelectedCell!.item]
                    destinationVC.selectedDate = date
                    destinationVC.selectedMonth = currentMonthShown
                    destinationVC.selectedYear = currentYearShown
                }
                
//                print("createInterviewScheduleSegue")
//                print(lastSelectedCell!.item)
//                print(date)
//                print(currentMonthShown!)
//                print(currentYearShown!)
            }
        } else if segue.identifier == "viewDateInterviewScheduleSegue" {
            if let destinationVC = segue.destination as? ViewSingleDateInterviewScheduleCollectionViewController {
                let date = dates[lastSelectedCell!.item] 
                
                destinationVC.selectedDate = date
                destinationVC.selectedMonth = currentMonthShown
                destinationVC.selectedYear = currentYearShown
                
//                print("viewDateInterviewScheduleSegue")
//                print(date)
//                print(currentMonthShown!)
//                print(currentYearShown!)
            }
        }
        
    }
    
    
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
        
        // reset all cell properties that change
        cell.backgroundColor = UIColor.systemGray5 // default background color
        cell.dateLabel.textColor = UIColor.black    // default text color
        cell.dateLabel.font = UIFont.preferredFont(forTextStyle: .body) // default font
        
        // reset border appearance that changes when user selects a cell
        cell.layer.borderWidth = 0 // reset border width
        cell.layer.borderColor = UIColor.clear.cgColor // reset border color
        
        // Configure the cell
        if indexPath.section == DAY_HEADER_SECTION {
            let day = dayHeaderList[indexPath.item]
            cell.dateLabel.text = day
            
            //TODO: remove
            cell.backgroundColor = UIColor.systemGray3
            
        } else if indexPath.section == DATES_SECTION {
            let date = dates[indexPath.item]
            
            //TODO: remove
            cell.backgroundColor = UIColor.systemGray5
            
            // front of dates list is prefilled with 100 just so we start on the right index when creating the calendar
            // so if the date is 100, just show an empty string on the label
            if date == 100 {
                cell.dateLabel.text = ""
            } else {
                cell.dateLabel.text = String(date)
                
                // check if this cell represents today's date
                if isToday(date: date) {
                    // set lastSelectedDate to the cell for today's date
                    lastSelectedCell = [DATES_SECTION, indexPath.item]
                    
                    // highlight today's date
                    cell.backgroundColor = UIColor.systemIndigo
                    
                    // Make font bold and change font colour
                    let systemFontSize = UIFont.preferredFont(forTextStyle: .body).pointSize
                    let boldBodyFont = UIFont.systemFont(ofSize: systemFontSize, weight: .bold)
                    
                    cell.dateLabel.font = boldBodyFont
                    cell.dateLabel.textColor = UIColor.white
                }
            }
        }
        return cell
    }
    
    // function to identify if a cell is today's date
    func isToday(date: Int) -> Bool {
        todayDay = calendar.component(.day, from: todayDate)
        todayYear = calendar.component(.year, from: todayDate)
        todayMonth = calendar.component(.month, from: todayDate)

        // Only highlight if the year, month, and day match
        return todayDay == date && todayYear == currentYearShown && todayMonth == currentMonthShown
    }
    

    // MARK: Collection View Layout Settings/Configuration
    
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
        itemLayout.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 2, bottom: 0, trailing: 2)
        
        // set fixed height
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(30))
        let layoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [itemLayout])
        
        let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
        layoutSection.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 25, bottom: 10, trailing: 25)
        
        // Define header for month label
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(90))
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        layoutSection.boundarySupplementaryItems = [header]
        
        return layoutSection
    }
        
    func calendarDatesSectionLayout() -> NSCollectionLayoutSection {
        // Tiled layout
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/7), heightDimension: .fractionalHeight(1))
        let itemLayout = NSCollectionLayoutItem(layoutSize: itemSize)
        // Add padding around each item
        itemLayout.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 2, bottom: 0, trailing: 2)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1/9))
        let layoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [itemLayout])
        
        let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
        layoutSection.interGroupSpacing = 5
        layoutSection.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 25, bottom: 15, trailing: 25)
        
        return layoutSection
    }
    
    // To set section header title
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "monthTitleCell", for: indexPath) as? InterviewScheduleMonthCollectionReusableView {
            
            // set month label
            var components = DateComponents()
            components.year = currentYearShown
            components.month = currentMonthShown
            
            // create a date object from month and year only
            if let monthDate = calendar.date(from: components) {
                dateFormatter.dateFormat = "MMM YYYY"
                sectionHeader.headerLabel.text = dateFormatter.string(from: monthDate)
            } else {
                print("Failed to create date from components")
            }
            
            return sectionHeader
        }
        return UICollectionReusableView()
    }

    
    // MARK: Arrow Button Action Functions
    
    @IBAction func onRightArrowButtonClick(_ sender: Any) {
        if currentMonthShown == 12 {
            currentMonthShown = 1
            currentYearShown! += 1
        } else {
            currentMonthShown! += 1
        }
        
        // set lastSelectedIndex to select nothing
        lastSelectedCell = nil
        
        // reset and recalculate the number of cells we should display for new month
        dates = []
        getNumOfCellsInCalendarMonth()
        
        collectionView.reloadData()
    }
    
    @IBAction func onLeftArrowButtonClick(_ sender: Any) {
        if currentMonthShown == 1 {
            currentMonthShown = 12
            currentYearShown! -= 1
        } else {
            currentMonthShown! -= 1
        }
        
        // set lastSelectedIndex to select nothing
        lastSelectedCell = nil
        
        // reset and recalculate the number of cells we should display for new month
        dates = []
        getNumOfCellsInCalendarMonth()
        
        collectionView.reloadData()
    }
    
    
    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */
    
    // function to highlight cell that is selected
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // check if there's a previously selected cell
        // if there is, check if it's different from the current selection
        // reset borders of previously selected cell
        if let lastIndexPath = lastSelectedCell, lastIndexPath != indexPath {
            // Get the previous cell and reset its border
            if let lastCell = collectionView.cellForItem(at: lastIndexPath) as? InterviewScheduleCollectionViewCell {
                lastCell.layer.borderWidth = 0
            }
        }

        // update border of current/new selected cell to red
        if let cell = collectionView.cellForItem(at: indexPath) as? InterviewScheduleCollectionViewCell {
            cell.layer.borderWidth = 1.5
            cell.layer.borderColor = UIColor.red.cgColor
        }

        // update last selected index path var
        lastSelectedCell = indexPath
//        print(lastSelectedCell)
    }

    
    // this method specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        // make the day headers (section 0 - DAY_HEADER_SECTION) unselectable
        if indexPath.section == DAY_HEADER_SECTION {
            return false
        }
        
        // for DATES_SECTION (section 1)
        let date = dates[indexPath.item]
        if date == 100 {
            // 100 are placeholder cells that shouldn't be selectable
            return false
        }
        
        return true
    }
    

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
