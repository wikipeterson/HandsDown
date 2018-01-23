//
//  Class.swift
//  HandsDown
//
//  Created by  on 1/12/18.
//  Copyright © 2018 WikipetersonAssistStatApps. All rights reserved.
//

import UIKit
import CloudKit

class Class
{
    
    var name : String = ""
    var students = [Student]()
    // recordID is used for cloudkit.  Each record of class has a unique id.  The recordid is the uniqueID.  It is important for relating the class to the students.
    var recordID: String = ""
    var record: CKRecord?
    // this is used for notification that gets called after students get loaded.
    static let studentsLoadedNotification = "studentsLoadedNotification"
    
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

        self.record = record
        self.students = []
        
        // figure out how to images
        
        // load students
        let privateDatabase = CKContainer.default().privateCloudDatabase
        
        let recordToMatch = CKReference(record: record, action: .deleteSelf)
        let predicate = NSPredicate(format: "classID == %@", recordToMatch)
        
        let query = CKQuery(recordType: "Student", predicate: predicate)
        
        // Configure Query.  Figure out a better way to sort.  Maybe sort by created?
        query.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        privateDatabase.perform(query, inZoneWith: nil) {
            (records, error) in
            guard let records = records else {
                print("Error querying records: ", error as Any)
                return
            }
            print("Found \(records.count) student records matching query")

            for record in records {
                // create a student from the record
                let foundStudent = Student(record: record)
                // append to students array
                self.students.append(foundStudent)
            }
            DispatchQueue.main.async {
                self.deliverStudentsLoadedNotification()
            }
            
            
        }
    }
    
    private func deliverStudentsLoadedNotification() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Class.studentsLoadedNotification), object: nil)
    }

    
    //this is a methode for randomizing the order of students within a class
    func shuffle()
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
