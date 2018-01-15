//
//  Student.swift
//  HandsDown
//
//  Created by Christopher Walter on 1/10/18.
//  Copyright © 2018 WikipetersonAssistStatApps. All rights reserved.
//

import UIKit

class Student
{
    var name: String = "default name"
    var picture: UIImage = #imageLiteral(resourceName: "sampleStudentImage")

    
    init(name: String, picture: UIImage)
    {
        self.name = name
        self.picture = picture
    }

}
