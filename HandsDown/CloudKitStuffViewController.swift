//
//  CloudKitStuffViewController.swift
//  HandsDown
//
//  Created by Christopher Walter on 1/30/18.
//  Copyright © 2018 WikipetersonAssistStatApps. All rights reserved.
//

import UIKit
import CloudKit

class CloudKitStuffViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // this will grab user data
        CKContainer.default().fetchUserRecordID { (recordID, error) in
            if let error = error {
                print(error)
            } else if let recordID = recordID {
                print(recordID)
            }
        }
    }

//    func loadClassesFromCloudKit() {
//        let privateDatabase = CKContainer.default().privateCloudDatabase
//        
//        // Initialize Query
//        // look more into Predicates.  You can query by name, distance form, etc.
//        let predicate = NSPredicate(value: true)
//        let query = CKQuery(recordType: "Class", predicate: predicate)
//        
//        // Configure Query.  Figure out a better way to sort.  Maybe sort by created?
//        query.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
//        
//        privateDatabase.perform(query, inZoneWith: nil) {
//            (records, error) in
//            guard let records = records else {
//                print("Error querying records: ", error as Any)
//                return
//            }
//            print("Found \(records.count) class records matching query")
//            // clear classes. then reload
//            self.teacher.classes.removeAll()
//            for record in records {
//                let foundClass = Class(record: record) // create a class from the record
//                self.teacher.classes.append(foundClass)
//            }
//            DispatchQueue.main.async(execute: {
//                self.tableView.reloadData()
//            })
//        }
//    }
    
//    func loadStudentsFromCloudKit() {
//        let privateDatabase = CKContainer.default().privateCloudDatabase
//        
//        // Initialize Query
//        // look more into Predicates.  You can query by name, distance from, etc.
//        guard var currentClass = myClass else {return}
//        
//        // search for all students with the classID = to the class's recordID
//        // Match item records whose owningList field points to the specified list record.
//        let classRecord = currentClass.record
//        
//        let recordToMatch = CKReference(record: classRecord!, action: .deleteSelf)
//        let predicate = NSPredicate(format: "classID == %@", recordToMatch)
//        
//        //        let predicate = NSPredicate(format: "%K = %@", "classID", currentClass.recordID)
//        //       let predicate = NSPredicate(value: true)
//        let query = CKQuery(recordType: "Student", predicate: predicate)
//        
//        // Configure Query.  Figure out a better way to sort.  Maybe sort by created?
//        query.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
//        
//        privateDatabase.perform(query, inZoneWith: nil) {
//            (records, error) in
//            guard let records = records else {
//                print("Error querying records: ", error as Any)
//                return
//            }
//            print("Found \(records.count) records matching query")
//            // clear classes. then reload
//            
//            currentClass.students.removeAll()
//            for record in records {
//                let foundStudent = Student(record: record) // create a student from the record
//                // append to students array
//                currentClass.students.append(foundStudent)
//            }
//            self.myClass?.students = currentClass.students
//            // this will prevent crash because we are working on a background thread.  We might not need this, but it was needed for async calls in firebase
//            DispatchQueue.main.async(execute: {
//                self.myTableView.reloadData()
//            })
//            
//            
//        }
//    }

}
