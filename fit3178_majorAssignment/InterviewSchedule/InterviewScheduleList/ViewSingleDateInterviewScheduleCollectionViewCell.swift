//
//  ViewSingleDateInterviewScheduleCollectionViewCell.swift
//  jobApplication_prepTrack_app
//
//  Created by Chin Yen Tung on 17/5/2024.
//

import UIKit

class ViewSingleDateInterviewScheduleCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var startDatetimeLabel: UILabel!
    @IBOutlet weak var endDatetimeLabel: UILabel!
    
    // https://developer.apple.com/documentation/objectivec/nsobject/1402907-awakefromnib
    // awakeFromNib called after the cell has loaded onto the storyboard
    // typically implemented for objects that require additional set up that cannot be done at design time.
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Apply rounded corners
        contentView.layer.cornerRadius = 10.0
        contentView.layer.masksToBounds = true
                
        // Set masksToBounds to false to avoid the shadow
        // from being clipped to the corner radius
        layer.cornerRadius = 10.0
        layer.masksToBounds = false
    }
}
