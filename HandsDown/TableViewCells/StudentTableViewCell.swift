//
//  StudentTableViewCell.swift
//  HandsDown
//
//  Created by Christopher Walter on 1/30/18.
//  Copyright © 2018 WikipetersonAssistStatApps. All rights reserved.
//

import UIKit

class StudentTableViewCell: UITableViewCell {

    @IBOutlet weak var studentImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    var student: Student? {
        didSet {
            self.layer.cornerRadius = 4.0
            self.layer.borderColor = UIColor.lightGray.cgColor
            self.layer.borderWidth = 1.0
            studentImageView.layer.cornerRadius = 50.0
            nameLabel.text = student?.name
            studentImageView.image = student?.photo
            
            let height = studentImageView.bounds.height
            studentImageView.layer.cornerRadius = height / 2.0
            studentImageView.layer.masksToBounds = true
            studentImageView.layer.borderColor = UIColor.lightGray.cgColor
            studentImageView.layer.borderWidth = 2.0
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
