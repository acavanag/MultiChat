//
//  MessageTableViewCell.swift
//  
//
//  Created by Andrew Cavanagh on 6/21/15.
//
//

import UIKit

class MessageTableViewCell: UITableViewCell {
    
    @IBOutlet weak var senderLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
