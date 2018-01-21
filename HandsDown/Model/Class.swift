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
    // recordID is used for cloudkit.  Each record of class has a unique id.  The recordid is the uniqueID.  It is important for relating the class to the students.
    var recordID: String = ""
    var record: CKRecord?
    
    init() {
        name = ""
        recordID = ""
        students = []
        record = nil
    }
    init(name: String, students: [Student]) {
        self.name = name
        self.students = students
        self.recordID = ""
        self.record = nil
    }
    init(record: CKRecord) {
        self.name = record["name"] as? String ?? ""
        self.recordID = record["referenceName"] as? String ?? ""
        // figure out how to load students and images
        self.students = []
        self.record = record
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
