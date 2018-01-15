//
//  Class.swift
//  HandsDown
//
//  Created by  on 1/12/18.
//  Copyright © 2018 WikipetersonAssistStatApps. All rights reserved.
//

import UIKit
import CloudKit

struct Class
{
    
    var name : String = ""
    var students = [Student]()
    
    init() {
        name = ""
        students = []
    }
    init(name: String, students: [Student]) {
        self.name = name
        self.students = students
    }
    init(record: CKRecord) {
        self.name = record["name"] as? String ?? ""
        // figure out how to load students and images
        self.students = []
    }
//    init (){
//        self.name = ""
//        self.students = []
//    }
//    init (name: String, students: [Student]){
//        self.name = name
//        self.students = students
//    }
    

}
