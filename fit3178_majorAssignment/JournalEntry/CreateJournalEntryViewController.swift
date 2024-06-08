//
//  CreateJournalEntryViewController.swift
//  jobApplication_prepTrack_app
//
//  Created by Chin Yen Tung on 2/5/2024.
//

import UIKit

class CreateJournalEntryViewController: UIViewController {

    @IBOutlet weak var categoriesCollectionView: UICollectionView!
    
    @IBOutlet weak var entryTitleTextField: UITextField!
    @IBOutlet weak var entryDatePicker: UIDatePicker!
    @IBOutlet weak var entryDescTextField: UITextView!
    
    weak var databaseController: DatabaseProtocol?
    var allCategoryList = ["Leadership", "Communication", "Adaptability", "Time Management", "Problem Solving", "Teamwork"]
    var arrSelectedIndex = [IndexPath]() // to store selected cell Index array
    var arrSelectedCategoryData = [String]() // To store selected cell category data array
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // add borders to entry desc text view
        entryDescTextField!.layer.borderWidth = 1
        entryDescTextField!.layer.borderColor = UIColor(red: 0.94, green: 0.94, blue: 0.94, alpha: 1.00).cgColor
        entryDescTextField!.layer.cornerRadius = 5.0

        // Do any additional setup after loading the view.
        let appDelegate = UIApplication.shared.delegate as? AppDelegate // get access to the AppDelegate
        databaseController = appDelegate?.databaseController    // store a reference to the databaseController
        
        // setup collection view
        categoriesCollectionView.dataSource = self
        categoriesCollectionView.delegate = self
        
        // set collection view layout
        categoriesCollectionView.setCollectionViewLayout(UICollectionViewCompositionalLayout(section: createCategoriesLayout()), animated: false)
    }
    
    @IBAction func onAddEntryClick(_ sender: Any) {
        // validate the user input
        guard let title = entryTitleTextField.text, let desc = entryDescTextField.text else {
            return
        }
        // - ensure name and abilities are not empty
        if title.isEmpty || desc.isEmpty || arrSelectedIndex.count == 0{
            var errorMsg = "Please ensure all fields are filled:\n"
            
            if title.isEmpty {
                errorMsg += "- Title must be provided\n"
            }
            if arrSelectedIndex.count == 0 {
                errorMsg += "- Category must be provided\n"
            }
            if desc.isEmpty {
                errorMsg += "- Description must be provided\n"
            }
            displayMessage(title: "Missing Fields", message: errorMsg)
            return
        }
        
        // format date and convert to string
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current   // used to ensure that app adapts to user's language and region settings
        dateFormatter.dateFormat = "dd-MMM-yyyy" // set date format
        let dateString = dateFormatter.string(from: entryDatePicker.date) // convert to string
        
        let _ = databaseController?.addJournalEntry(entryTitle: title, entryDate: dateString, entryCategories: arrSelectedCategoryData, entryDes: desc)
        navigationController?.popViewController(animated: true)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: collection view layout
    
    func createCategoriesLayout() -> NSCollectionLayoutSection {
        let fixedHeight: CGFloat = 30 // create var for fixed cell height
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(fixedHeight))
        let itemLayout = NSCollectionLayoutItem(layoutSize: itemSize)
        // Add padding around each item
        itemLayout.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 2, bottom: 0, trailing: 2)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(fixedHeight))
        let layoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [itemLayout])
        
        let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
        layoutSection.interGroupSpacing = 5
        
        //layoutSection.orthogonalScrollingBehavior = .continuous
        return layoutSection
    }
}

// MARK: Collection view controller

// reference - https://stackoverflow.com/questions/52757524/how-do-i-got-multiple-selections-in-uicollection-view-using-swift-4
extension CreateJournalEntryViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.allCategoryList.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "journalCategoryCollectionViewCellIdentifier", for: indexPath) as! JournalCategoryCollectionViewCell
        
        // add category labels to each cell
        cell.categoryLabel.text = allCategoryList[indexPath.row]
        
        if arrSelectedIndex.contains(indexPath) {
            // if user has selected a cell, change the cell colour
            // #999999 colour
            cell.backgroundColor = UIColor(red: 0.60, green: 0.60, blue: 0.60, alpha: 1.00)
        }
        else {
            // #D9D9D9 colour
            cell.backgroundColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1.00)
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        print("You selected cell index #\(indexPath.item)!")
//        print("You selected cell #\(allCategoryList[indexPath.item])")
        
        let selectedCategory = allCategoryList[indexPath.item]

        // check if item is already selected, if already selected:
        if arrSelectedIndex.contains(indexPath) {
            // deselect it by filtering arrSelectedIndex & arrSelectedData lists
            // to only include items that are != indexPath and != selectedCategory
            // which creates 2 new lists that doesnt include those items
            arrSelectedIndex = arrSelectedIndex.filter { $0 != indexPath}
            arrSelectedCategoryData = arrSelectedCategoryData.filter { $0 != selectedCategory}
        }
        else {
            // add selected category to arrSelectedIndex and arrSelectedData lists
            arrSelectedIndex.append(indexPath)
            arrSelectedCategoryData.append(selectedCategory)
        }
        collectionView.reloadData()
    }
}
