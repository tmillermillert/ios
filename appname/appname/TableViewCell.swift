//
//  TableViewCell.swift
//  appname
//
//  Created by Marcus Tanner Miller on 4/9/20.
//  Copyright © 2020 Marcus Tanner Miller. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {
    
    @IBOutlet weak var placeCellTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    

}
