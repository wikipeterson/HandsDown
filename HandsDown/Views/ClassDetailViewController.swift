//
//  ClassDetailViewController.swift
//  HandsDown
//
//  Created by  on 1/14/18.
//  Copyright © 2018 WikipetersonAssistStatApps. All rights reserved.
//

import UIKit
import CloudKit

protocol updateTeacherDelegate {
    func updateTeacher(teacher: Teacher)
}

class ClassDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate, UITextFieldDelegate, AddStudentDelegate {

    // MARK:  Outlets
    @IBOutlet weak var tableViewNavBar: UINavigationBar!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var addStudentButton: UIBarButtonItem!
    var editSwitch = true
    var teacher = Teacher() // this should get passed over from classVC
    var currentClass: Class?
    var delegate: updateTeacherDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // this will remove extra unsed rows from tableview
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.backgroundColor = UIColor.clear
        
        navigationController?.delegate = self

        setUpNavBar()
        
        if let theCurrentClass = currentClass {
            nameTextField.text = theCurrentClass.name
        } else {
            nameTextField.text = ""
            nameTextField.becomeFirstResponder()
        }
    }
    // we might not need this anymore.
    override func viewWillDisappear(_ animated: Bool) {
//        let name = nameTextField.text ?? ""
        teacher.currentClass = currentClass
//        saveOrUpdateClassToCloudKit(name: name)
        delegate?.updateTeacher(teacher: teacher)
    }
    
    func setUpNavBar () {
        tableViewNavBar.backgroundColor = UIColor.gray
        tableViewNavBar.tintColor = UIColor.white
        tableViewNavBar.layer.cornerRadius = 4.0
        
        let font = UIFont(name: "Avenir Book", size: 25)
        //let color = UIColor(red: 27.0/255.0, green: 176.0/255.0, blue: 255.0/255.0, alpha: 1.0)
        let color = UIColor.mintDark
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
    
//    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
//        let name = nameTextField.text ?? ""
//        saveOrUpdateClassToCloudKit(name: name)
//        delegate?.updateTeacher(teacher: teacher)
//        navigationController?.popViewController(animated: true)
//    }
    
    // MARK: AddStudentDelegate Methods
    func addStudent(student: Student) {
        teacher.currentClass?.students.append(student)
        tableView.reloadData()
    }
    
    func updateStudent(student: Student) {
        // find location of student in studentArray, update values, the reload tableview
        if let myClass = teacher.currentClass {
            for index in 0..<myClass.students.count {
                if myClass.students[index].recordName == student.recordName {
                    teacher.currentClass?.students[index] = student
                    tableView.reloadData()
                    break
                }
            }
        }
    }
    // Mark: CloudKit Methods
    func saveOrUpdateClassToCloudKit(name: String) {
        // create a new record in cloudkit if nil
        if currentClass == nil {
            // create the CKRecord that gets saved to the database

            let uid = UUID().uuidString // get a uniqueID
            let recordID = CKRecordID(recordName: uid)
            let newClassRecord = CKRecord(recordType: "Class", recordID: recordID)
            newClassRecord["name"] = name as NSString
            
            // save CKRecord to correct container.. private, public, shared, etc.
            let myContainer = CKContainer.default()
            let privateDatabase = myContainer.privateCloudDatabase
            privateDatabase.save(newClassRecord) {
                (record, error) in
                if let error = error {
                    print(error)
                    return
                }
                let newClass = Class(record: newClassRecord)
                self.teacher.classes.append(newClass)
                self.teacher.currentClass = newClass
                self.currentClass = newClass
                
                DispatchQueue.main.async(execute: {
                    self.delegate?.updateTeacher(teacher: self.teacher)
                    print("created new class:\(newClass.name)")
                })
            }
        } else {
            // update the class
            // make sure you save the new class name if the user changes the nameTextField.
            if currentClass?.name != nameTextField.text {
                let newName = nameTextField.text ?? ""
                currentClass?.name = newName
                // save to cloudkit as well
                if let record = currentClass?.record {
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
        
    }
    func deleteRecordFromCloudKit(myStudent: Student) {
        let privateDatabase = CKContainer.default().privateCloudDatabase
        
        guard let record = myStudent.record else {return}
        privateDatabase.delete(withRecordID: record.recordID, completionHandler: {(recordID, error) in
            if let err = error {
                print(err)
                return
            } else {
//                print("Successfully deleted:", recordID as Any)
            }
        })
    }
    // MARK:  TableView methods
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 124.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if let theClass = currentClass {
            return theClass.students.count
        }
        else {
            return 0
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "studentCell", for: indexPath) as! StudentTableViewCell
        if let theClass = currentClass {
            let student = theClass.students[indexPath.row]
            cell.student = student // properties are set in didSet method in studentTVC
            cell.numberLabel.text = "\(indexPath.row + 1)"
            
        }
        return cell
    }
    

    //this is the code needed to delete a row...
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath)
    {
   
        // delete from cloudkit
        if let myStudent = currentClass?.students[indexPath.row] {
            deleteRecordFromCloudKit(myStudent: myStudent)
            currentClass?.students.remove(at: indexPath.row)
        }
        tableView.reloadData()
    }
    //this is the code needed to move items in the tableview
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath)
    {
        if let itemToMove = currentClass?.students[sourceIndexPath.row] {
            currentClass?.students.remove(at: sourceIndexPath.row)
            
            currentClass?.students.insert(itemToMove, at: destinationIndexPath.row)
        }
        tableView.reloadData() // if you don't reload data the numbers will be goofy
    }
    
    // MARK: TextField methods
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        let name = nameTextField.text ?? ""
        saveOrUpdateClassToCloudKit(name: name)
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if nameTextField.isEditing {
            let name = nameTextField.text ?? ""
            saveOrUpdateClassToCloudKit(name: name)
        }
        self.view.endEditing(true)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "editStudentSegue" {
            teacher.currentClass = currentClass
            let destVC = segue.destination as! StudentViewController
            if let indexPath = tableView.indexPathForSelectedRow {
                let row = indexPath.row
                let theStudent = teacher.currentClass?.students[row]
                destVC.student = theStudent
                destVC.teacher = teacher
                destVC.delegate = self
            }
            
        } else if segue.identifier == "addStudentSegue" {
            teacher.currentClass = currentClass
            let name = nameTextField.text ?? ""
            saveOrUpdateClassToCloudKit(name: name)
            let destVC = segue.destination as! StudentViewController
            destVC.student = nil
            destVC.delegate = self
            destVC.teacher = teacher
        }
            
        
    }
    
    
}
