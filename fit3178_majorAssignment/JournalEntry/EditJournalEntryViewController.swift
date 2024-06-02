//
//  EditJournalEntryViewController.swift
//  jobApplication_prepTrack_app
//
//  Created by Chin Yen Tung on 2/5/2024.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class EditJournalEntryViewController: UIViewController {
    var currentJournalEntry: JournalEntry?
    var dateFormatter = DateFormatter()
    
    // initialise firestore database and authentication
    var db: Firestore = Firestore.firestore()
    var authController: Auth = Auth.auth()

    @IBOutlet weak var categoriesCollectionView: UICollectionView!
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var entryDescTextField: UITextView!
    
    var allCategoryList = ["Leadership", "Communication", "Adaptability", "Time Management", "Problem Solving", "Teamwork"]
    var arrSelectedIndex = [IndexPath]() // to store selected cell Index array
    var arrSelectedCategoryData = [String]() // To store selected cell category data array
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // add borders to entry desc text view
        entryDescTextField!.layer.borderWidth = 1
        entryDescTextField!.layer.borderColor = UIColor(red: 0.94, green: 0.94, blue: 0.94, alpha: 1.00).cgColor
        entryDescTextField!.layer.cornerRadius = 5.0
        
        // TODO: get date in string
        dateFormatter.locale = Locale.current   // used to ensure that app adapts to user's language and region settings
        dateFormatter.dateFormat = "dd-MMM-yyyy" // set date format
        let date = dateFormatter.date(from: (currentJournalEntry?.entryDate)!)
        datePicker.date = date!
        
        // TODO: handle categories
        arrSelectedCategoryData = (currentJournalEntry?.entryCategories)!

        titleTextField.text = currentJournalEntry?.entryTitle
        entryDescTextField.text = currentJournalEntry?.entryDes
        
        // setup collection view
        categoriesCollectionView.dataSource = self
        categoriesCollectionView.delegate = self
        
        // set collection view layout
        categoriesCollectionView.setCollectionViewLayout(UICollectionViewCompositionalLayout(section: createCategoriesLayout()), animated: false)
    }
    
    // TODO: implement code to edit journal details
    @IBAction func onSaveEntry(_ sender: Any) {
        // validate the user input
        guard let title = titleTextField.text, let desc = entryDescTextField.text else {
            return
        }
        // - ensure name and abilities are not empty
        if title.isEmpty || desc.isEmpty || arrSelectedCategoryData.count == 0{
            var errorMsg = "Please ensure all fields are filled:\n"
            
            if title.isEmpty {
                errorMsg += "- Title must be provided\n"
            }
            if arrSelectedCategoryData.count == 0 {
                errorMsg += "- Category must be provided\n"
            }
            if desc.isEmpty {
                errorMsg += "- Description must be provided\n"
            }
            displayMessage(title: "Missing Fields", message: errorMsg)
            return
        }
        
        // format date and convert to string
        dateFormatter.locale = Locale.current   // used to ensure that app adapts to user's language and region settings
        dateFormatter.dateFormat = "dd-MMM-yyyy" // set date format
        let dateString = dateFormatter.string(from: datePicker.date) // convert to string
        
        // get id of current journal entry in firebase
        let documentId = currentJournalEntry?.id
        
        // get database of current user
        let currentUserUID = authController.currentUser?.uid
//        print(currentUserUID!)
        let userDb = db.collection("users").document(currentUserUID!)
        
        // get updated data from UI, edit the document in firebase, and save it
        userDb.collection("journalEntry").document(documentId!).updateData([
            "entryTitle": title,
            "entryDes": desc,
            "entryDate": dateString,
            "entryCategories": arrSelectedCategoryData
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
            }
        }
        
        // navigate back to previous screen
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
        
        return layoutSection
    }
}

// MARK: Collection view controller

// reference - https://stackoverflow.com/questions/52757524/how-do-i-got-multiple-selections-in-uicollection-view-using-swift-4
extension EditJournalEntryViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.allCategoryList.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "journalCategoryCollectionViewCellIdentifier", for: indexPath) as! EditJournalCategoryCollectionViewCell
        
        // add category labels to each cell
        cell.categoryLabel.text = allCategoryList[indexPath.row]
        
        if arrSelectedCategoryData.contains(allCategoryList[indexPath.row]) {
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
        if arrSelectedCategoryData.contains(selectedCategory) {
            // deselect it by filtering arrSelectedCategoryData lists
            // to only include items that are != selectedCategory
            // which creates a new list that doesnt include those items
            arrSelectedCategoryData = arrSelectedCategoryData.filter { $0 != selectedCategory}
        }
        else {
            // add selected category to arrSelectedCategoryData lists
            arrSelectedCategoryData.append(selectedCategory)
        }
        collectionView.reloadData()
    }
}


