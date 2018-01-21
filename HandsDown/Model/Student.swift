//
//  Student.swift
//  HandsDown
//
//  Created by Christopher Walter on 1/10/18.
//  Copyright © 2018 WikipetersonAssistStatApps. All rights reserved.
//

import UIKit
import CloudKit

class Student
{
    var name: String = "default name"
    var picture: UIImage = #imageLiteral(resourceName: "sampleStudentImage")
    
    var classID: String = ""

    
    init(name: String, picture: UIImage)
    {
        self.name = name
        self.picture = picture
        self.classID = ""
    }
    
    init(record: CKRecord) {
        self.name = record["name"] as? String ?? ""
        self.classID = record["classID"] as? String ?? ""
        // figure out how to load students and images
        picture = #imageLiteral(resourceName: "Monkey")
    }
    

}
