//
//  PlaceTableViewCell.swift
//  StreamTest
//
//  Created by Dmitry Rybochkin on 01.04.17.
//  Copyright © 2017 Dmitry Rybochkin. All rights reserved.
//

import UIKit

class PlaceTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var sheduleLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
