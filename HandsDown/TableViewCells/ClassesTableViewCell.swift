//
//  ClassesTableViewCell.swift
//  HandsDown
//
//  Created by Christopher Walter on 1/30/18.
//  Copyright © 2018 WikipetersonAssistStatApps. All rights reserved.
//

import UIKit

class ClassesTableViewCell: UITableViewCell {

    @IBOutlet weak var classDetailLabel: UILabel!
    @IBOutlet weak var classNameLabel: UILabel!

    var theClass: Class? {
        didSet {
            self.layer.cornerRadius = 4.0
            self.layer.borderColor = UIColor.lightGray.cgColor
            self.layer.borderWidth = 1.0
            
            classNameLabel.text = theClass?.name
            let numberOfStudents = theClass?.students.count ?? 0
            classDetailLabel.text = "\(numberOfStudents) students"
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
