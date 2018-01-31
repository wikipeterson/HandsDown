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

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    var editSwitch = true
    var teacher = Teacher() // this should get passed over from classVC
    
    var defaultImagesArray = [#imageLiteral(resourceName: "beeImage"),#imageLiteral(resourceName: "sampleStudentImage"), #imageLiteral(resourceName: "foxImage"), #imageLiteral(resourceName: "questionMarkImage")]
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // this will remove extra unsed rows from tableview
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.backgroundColor = UIColor.clear
        
        navigationController?.delegate = self

        
        if let currentClass = teacher.currentClass {
            nameTextField.text = currentClass.name
        }
    }

    @IBAction func editButtonTapped(_ sender: UIBarButtonItem)
    {
        if editSwitch == true {
            tableView.isEditing = true
            editSwitch = false
            sender.title = "Done"
        }
        else {
            tableView.isEditing = false
            editSwitch = true
            sender.title = "Edit"
        }
    }
    
    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
        
    }
    
    @IBAction func addStudentButtonTapped(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Add a student", message: nil, preferredStyle: .alert)
        alert.addTextField(configurationHandler: {textfield in textfield.placeholder = "Name"})
        
        let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
            let newName = alert.textFields![0].text!
            let randomImageIndex = Int(arc4random_uniform(UInt32(self.defaultImagesArray.count)))
            let newPicture = self.defaultImagesArray[randomImageIndex]
//            let newStudent = Student(name: newName, picture: newPicture)
            self.saveStudentToCloudKit(name: newName)
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
        if let currentClass = teacher.currentClass {
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
            // append newClass to classes array, then reload tableview
            let newStudent = Student(record: newStudentRecord)
            self.teacher.currentClass?.students.append(newStudent)
            
            DispatchQueue.main.async(execute: {
                self.tableView.reloadData()
            })
        }
    }
    func deleteRecordFromCloudKit(myStudent: Student) {
        let privateDatabase = CKContainer.default().privateCloudDatabase
        
        guard let record = myStudent.record else {return}
        privateDatabase.delete(withRecordID: record.recordID, completionHandler: {(recordID, error) in
            if let err = error {
                print(err)
                return
            } else {
                print("Successfully deleted:", recordID as Any)
            }
            
        })
    }
    
    // MARK:  TableView methods
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 124.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if let theClass = teacher.currentClass {
            return theClass.students.count
        }
        else {
            return 0
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "studentCell", for: indexPath) as! StudentTableViewCell
        if let theClass = teacher.currentClass {
            let student = theClass.students[indexPath.row]
            cell.student = student // properties are set in didSet method in studentTVC

        }
        
        return cell
    }
    

    //this is the code needed to delete a row...
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath)
    {
   
        // delete from cloudkit
        if let myStudent = teacher.currentClass?.students[indexPath.row] {
            deleteRecordFromCloudKit(myStudent: myStudent)
            teacher.classes.remove(at: indexPath.row)
        }
        tableView.reloadData()
    }
    //this is the code needed to move items in the tableview
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath)
    {
        if let itemToMove = teacher.currentClass?.students[sourceIndexPath.row] {
            teacher.currentClass?.students.remove(at: sourceIndexPath.row)
            
            teacher.currentClass?.students.insert(itemToMove, at: destinationIndexPath.row)
        }
    }
    
    
    // this might not be the best way of passing data backward
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool)
    {
    
        if let vc = viewController as? ClassesViewController
        {
            vc.teacher = teacher    // Here you pass the data back to your original view controller
        }
    }
    
    
}
