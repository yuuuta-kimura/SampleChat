//
//  YourTableCell.swift
//  SampleChat
//
//  Created by 木村 優太 on 2019/07/22.
//  Copyright © 2019 木村 優太. All rights reserved.
//

import UIKit

class YourTableCell: UITableViewCell {
    
    @IBOutlet weak var labelTextView: UILabel!
    @IBOutlet weak var autosizeView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func updateCell(_ chat: ChatSpeak) {
        self.labelTextView?.text = chat.text        
    }
}
