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

    @IBOutlet weak var tableViewNavBar: UINavigationBar!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    var editSwitch = true
    var teacher = Teacher() // this should get passed over from classVC
    
    var defaultImagesArray = [#imageLiteral(resourceName: "beeImage"),#imageLiteral(resourceName: "sampleStudentImage"), #imageLiteral(resourceName: "foxImage"), #imageLiteral(resourceName: "questionMarkImage"), #imageLiteral(resourceName: "Monkey")]
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // this will remove extra unsed rows from tableview
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.backgroundColor = UIColor.clear
        
        navigationController?.delegate = self

        
        if let currentClass = teacher.currentClass {
            nameTextField.text = currentClass.name
        }
        setUpNavBar()
    }
    
    func setUpNavBar () {
        tableViewNavBar.backgroundColor = UIColor.gray
        tableViewNavBar.tintColor = UIColor.white
        tableViewNavBar.layer.cornerRadius = 4.0
        
        let font = UIFont(name: "Avenir Book", size: 25)
        let color = UIColor(red: 27.0/255.0, green: 176.0/255.0, blue: 255.0/255.0, alpha: 1.0)
        tableViewNavBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: color, NSAttributedStringKey.font: font!]
        
        // do more to customize and make it look good
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
        saveClassName()
        navigationController?.popViewController(animated: true)
    }
    
    func saveClassName() {
        // make sure you save the new class name if the user changes the nameTextField.
        if teacher.currentClass?.name != nameTextField.text {
            let newName = nameTextField.text ?? ""
            teacher.currentClass?.name = newName
            // save to cloudkit as well
            if let record = teacher.currentClass?.record {
                record["name"] = newName as NSString
                let myContainer = CKContainer.default()
                let privateDatabase = myContainer.privateCloudDatabase
                privateDatabase.save(record) {
                    (record, error) in
                    if let error = error {
                        print(error)
                        return
                    }
                    // insert successfully saved record code...
                    print("Successfully updated record: ", record ?? "")
                }
            }
            
        }
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
        guard let currentClass = teacher.currentClass, let classRecord = currentClass.record else {return}

        let classReference = CKReference(record: classRecord, action: .deleteSelf)
        newStudentRecord["classID"] = classReference
    
        // to save picture, I need to save as a CKAsset.  To create CKAsset, first create temp url file, then save photo, and finally delete temp file from memory.  Seems like a lot and try to find a better way
        let randNumber = Int(arc4random_uniform(UInt32(defaultImagesArray.count)))
        let randomImage = defaultImagesArray[randNumber]
        let data = UIImagePNGRepresentation(randomImage)// UIImage -> NSData, see also UIImageJPEGRepresentation
        let url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(NSUUID().uuidString+".dat")
        do {
            try data!.write(to: url, options: [])
        } catch let e as NSError {
            print("Error! \(e)")
            return
        }
        newStudentRecord["photo"] = CKAsset(fileURL: url)
        
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
            
            // delete temp file for image data
            do {
                try FileManager.default.removeItem(at: url)
            } catch let e {
                print("Error deleting temp file: \(e)")
            }
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
            teacher.currentClass?.students.remove(at: indexPath.row)
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
