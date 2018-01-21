//
//  ClassDetailViewController.swift
//  HandsDown
//
//  Created by  on 1/14/18.
//  Copyright © 2018 WikipetersonAssistStatApps. All rights reserved.
//

import UIKit
import CloudKit

class ClassDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate {

    @IBOutlet weak var NameTextField: UITextField!
    @IBOutlet weak var myTableView: UITableView!
    var editSwitch = true
    var teacher = Teacher()
    var myClass: Class? // this should get passed over from classVC
    var defaultImagesArray = [#imageLiteral(resourceName: "beeImage"),#imageLiteral(resourceName: "sampleStudentImage"), #imageLiteral(resourceName: "foxImage"), #imageLiteral(resourceName: "questionMarkImage")]
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.delegate = self
        self.loadStudentsFromCloudKit()
        
    }

    @IBAction func editButtonTapped(_ sender: UIBarButtonItem)
    {
        if editSwitch == true
        {
            myTableView.isEditing = true
            editSwitch = false
           
           sender.title = "Done"
        }
        else
        {
            myTableView.isEditing = false
            editSwitch = true
           sender.title = "Edit" 
        }
    }
    
    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
        navigationController?.dismiss(animated: true, completion: nil)
        
        saveThisClass()
    }
    
    func saveThisClass()
    {
        // figure out how to save things here
        teacher.classes[teacher.currentClassID].students = (myClass?.students)!
        
    }
    
    
    @IBAction func addStudentButtonTapped(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Add a student", message: nil, preferredStyle: .alert)
        alert.addTextField(configurationHandler: {textfield in textfield.placeholder = "Name"})
        
        let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
            let newName = alert.textFields![0].text!
            let randomImageIndex = Int(arc4random_uniform(UInt32(self.defaultImagesArray.count)))
            let newPicture = self.defaultImagesArray[randomImageIndex]
            let newStudent = Student(name: newName, picture: newPicture)
            self.saveStudentToCloudKit(name: newName)
          
            // figure out how to load students after the save is finished.
            self.loadStudentsFromCloudKit()
//            self.myClass?.students.append(newStudent)
//            self.myTableView.reloadData()
            
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    // Mark: CloudKit Methods
    func saveStudentToCloudKit(name: String) {
        // create the CKRecord that gets saved to the database
        let uid = UUID().uuidString // get a uniqueID
        let recordID = CKRecordID(recordName: uid)
        let newStudentRecord = CKRecord(recordType: "Student", recordID: recordID)
        newStudentRecord["name"] = name as NSString
        
        
        // save classID to Student, so that we can fetch the students by classID
        if let currentClass = myClass {
//            let classID = CKRecordID(recordName: currentClass.recordID)
            guard let classRecord = currentClass.record else{return}
            let classReference = CKReference(record: classRecord, action: .deleteSelf)
//            let classReference = CKReference(recordID: classID, action: .deleteSelf)
            newStudentRecord["classID"] = classReference
        }
        // figure out how to save the picture
        
        // save CKRecord to correct container.. private, public, shared, etc.
        let myContainer = CKContainer.default()
        let privateDatabase = myContainer.privateCloudDatabase
        privateDatabase.save(newStudentRecord) {
            (record, error) in
            if let error = error {
                print(error)
                return
            }
            // insert successfully saved record code... reload table, etc...
            print("Successfully saved record: ", record ?? "")
        }
    }
    
    func loadStudentsFromCloudKit() {
        let privateDatabase = CKContainer.default().privateCloudDatabase
        
        // Initialize Query
        // look more into Predicates.  You can query by name, distance form, etc.
        guard var currentClass = myClass else {return}
        
        // search for all students with the classID = to the class's recordID
//        let predicate = NSPredicate(format: "%K = %@", "classID", currentClass.recordID)
       let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Student", predicate: predicate)
        
        // Configure Query.  Figure out a better way to sort.  Maybe sort by created?
        query.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        privateDatabase.perform(query, inZoneWith: nil) {
            (records, error) in
            guard let records = records else {
                print("Error querying records: ", error as Any)
                return
            }
            print("Found \(records.count) records matching query")
            // clear classes. then reload
            
            currentClass.students.removeAll()
            for record in records {
                let foundStudent = Student(record: record) // create a student from the record
                // append to students array
                currentClass.students.append(foundStudent)
            }
            self.myClass?.students = currentClass.students
            // this will prevent crash because we are working on a background thread.  We might not need this, but it was needed for async calls in firebase
            DispatchQueue.main.async(execute: {
//                print("we reloaded the table")
                self.myTableView.reloadData()
            })
//            self.myTableView.reloadData()
            
        }
    }
    
    // MARK:  TableView methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if let theClass = myClass {
            return theClass.students.count
        }
        else {
            return 0
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "studentCell", for: indexPath)
        if let theClass = myClass {
            let student = theClass.students[indexPath.row]
            cell.textLabel?.text = student.name
        } else {
            cell.textLabel?.text = "No Class in file"
        }
        
        return cell
    }
    

    //this is the code needed to delete a row...
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath)
    {
        teacher.classes[teacher.currentClassID].students.remove(at: indexPath.row)
        tableView.reloadData()
    }
    //this is the code needed to move items in the tableview
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath)
    {
        let itemToMove = teacher.classes[teacher.currentClassID].students[sourceIndexPath.row]
        teacher.classes[teacher.currentClassID].students.remove(at: sourceIndexPath.row)
        teacher.classes[teacher.currentClassID].students.insert(itemToMove, at: destinationIndexPath.row)
    }
    
    
    // this might not be the best way of passing data backward
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool)
    {
    
        if let vc = viewController as? ClassesViewController
        {
            saveThisClass()
            vc.teacher = teacher    // Here you pass the data back to your original view controller
        }
    }
    
    
}
