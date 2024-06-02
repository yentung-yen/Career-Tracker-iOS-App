//
//  ViewJournalEntryViewController.swift
//  jobApplication_prepTrack_app
//
//  Created by Chin Yen Tung on 2/5/2024.
//

import UIKit

class ViewJournalEntryViewController: UIViewController {
    var currentJournalEntry: JournalEntry?

    @IBOutlet weak var journalCategoryCollectionView: UICollectionView!
    var categoryList = [String]()
    
    @IBOutlet weak var entryTitleLabel: UILabel!
    @IBOutlet weak var entryDateLabel: UILabel!
    @IBOutlet weak var entryCategoryButton: UIButton!
    @IBOutlet weak var entryDescTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        entryTitleLabel.text = currentJournalEntry?.entryTitle
        entryDateLabel.text = currentJournalEntry?.entryDate
        categoryList = (currentJournalEntry?.entryCategories)!
//        print(categoryList.count)
        entryDescTextView.text = currentJournalEntry?.entryDes
        
        // setup collection view
        journalCategoryCollectionView.dataSource = self
        journalCategoryCollectionView.delegate = self
        
        // set collection view layout
        journalCategoryCollectionView.setCollectionViewLayout(UICollectionViewCompositionalLayout(section: createCategoriesLayout()), animated: false)
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "viewToEditJournalEntrySegue" {
            if let destinationVC = segue.destination as? EditJournalEntryViewController {
                destinationVC.currentJournalEntry = currentJournalEntry
            }
        }
    }
    
    
    // MARK: collection view layout
    
    func createCategoriesLayout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let itemLayout = NSCollectionLayoutItem(layoutSize: itemSize)
        // Add padding around each item
        itemLayout.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 2, bottom: 0, trailing: 2)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1/5))
        let layoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [itemLayout])
        
        let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
        layoutSection.interGroupSpacing = 5
        
        //layoutSection.orthogonalScrollingBehavior = .continuous
        return layoutSection
    }
}

// MARK: Collection view controller

extension ViewJournalEntryViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.categoryList.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "journalCategoryCollectionViewCellIdentifier", for: indexPath) as! ViewJournalCategoryCollectionViewCell
        
        // add category labels to each cell
        cell.categoryLabelButton.setTitle(categoryList[indexPath.row], for: .normal)
        
        return cell
    }
}
