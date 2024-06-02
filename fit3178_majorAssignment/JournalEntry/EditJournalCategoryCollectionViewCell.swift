//
//  EditJournalCategoryCollectionViewCell.swift
//  jobApplication_prepTrack_app
//
//  Created by Chin Yen Tung on 3/6/2024.
//

import UIKit

class EditJournalCategoryCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var categoryLabel: UILabel!
    
    // https://developer.apple.com/documentation/objectivec/nsobject/1402907-awakefromnib
    // awakeFromNib called after the cell has loaded onto the storyboard
    // typically implemented for objects that require additional set up that cannot be done at design time.
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Apply rounded corners
        contentView.layer.cornerRadius = 15
        contentView.layer.masksToBounds = true
                
        // Set masksToBounds to false to avoid the shadow
        // from being clipped to the corner radius
        layer.cornerRadius = 15
        layer.masksToBounds = false
        
        // set borders
        layer.borderWidth = 1.5
        layer.borderColor = UIColor.black.cgColor
    }
}
