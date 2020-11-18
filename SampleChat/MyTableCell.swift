//
//  YourTableCell.swift
//  SampleChat
//
//  Created by 木村 優太 on 2019/07/22.
//  Copyright © 2019 木村 優太. All rights reserved.
//

import UIKit

class MyTableCell: UITableViewCell
{
    
    @IBOutlet weak var labelTextView: UILabel!
    @IBOutlet weak var labelTimestamp: UILabel!
    @IBOutlet weak var autosizeView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
 
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func updateCell(_ chat: ChatSpeak) {
        self.labelTextView?.text = chat.text
        let df = DateFormatter()
        df.dateFormat = "yyyy/M/d\na h:m:s"
        df.locale = Locale(identifier: "ja_JP")
        self.labelTimestamp?.text = df.string(from: chat.time)
    }
    }

