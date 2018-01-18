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
    
    //this is a methode for randomizing the order of students within a class
    mutating func shuffle()
    {
        var shuffled = [Student]();
        
        for _ in 0..<self.students.count
        {
            let rand = Int(arc4random_uniform(UInt32(self.students.count)))
            
            shuffled.append(self.students[rand])
            
            self.students.remove(at: rand)
        }
        
        self.students = shuffled
    }
    
}
