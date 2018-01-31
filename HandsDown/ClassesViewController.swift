//
//  ClassesViewController.swift
//  HandsDown
//
//  Created by  on 1/13/18.
//  Copyright © 2018 WikipetersonAssistStatApps. All rights reserved.
//

import UIKit
import CloudKit

protocol SetTeacherDelegate {
    func setTeacher(teacher : Teacher)
}

class ClassesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    @IBOutlet weak var currentClassLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var editSwitch = true
    var teacher = Teacher()
    
    var delegate:SetTeacherDelegate?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        // this will remove extra unsed rows from tableview
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.backgroundColor = UIColor.clear
        

    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let currentClass = teacher.currentClass {
            currentClassLabel.text = currentClass.name
        }
    }
    
    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
       self.navigationController?.popViewController(animated: true)
        
        // save any changes here
        delegate?.setTeacher(teacher: teacher)
        
    }
    
    @IBAction func editButtonWasTapped(_ sender: UIBarButtonItem) {
        if editSwitch == true
        {
            tableView.isEditing = true
            editSwitch = false
            sender.title = "Done"
        }
        else
        {
            tableView.isEditing = false
            editSwitch = true
            sender.title = "Edit"

        }
    }
    
    @IBAction func addButtonWasTapped(_ sender: UIBarButtonItem) {

        let alert = UIAlertController(title: "Add a new class", message: nil, preferredStyle: .alert)
        alert.addTextField(configurationHandler: {textfield in textfield.placeholder = "Name of class"})
        let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
            let newClassName = alert.textFields![0].text!
//            let newClass = Class(name: newClassName, students: [Student]())
            self.saveClassToCloudKit(name: newClassName)
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    // Mark: CloudKit Methods
    func saveClassToCloudKit(name: String) {
        // create the CKRecord that gets saved to the database
        let uid = UUID().uuidString // get a uniqueID
        let recordID = CKRecordID(recordName: uid)
        let newClassRecord = CKRecord(recordType: "Class", recordID: recordID)
        newClassRecord["name"] = name as NSString
        // figure out how to save the picture
        
        // save CKRecord to correct container.. private, public, shared, etc.
        let myContainer = CKContainer.default()
        let privateDatabase = myContainer.privateCloudDatabase
        privateDatabase.save(newClassRecord) {
            (record, error) in
            if let error = error {
                print(error)
                return
            }
            // insert successfully saved record code... reload table, etc...
            print("Successfully saved record: ", record ?? "")
            // append newClass to classes array, then reload tableview
            let newClass = Class(record: newClassRecord)
            self.teacher.classes.append(newClass)
            DispatchQueue.main.async(execute: {
                self.tableView.reloadData()
            })
        }
    }
    
    func deleteRecordFromCloudKit(myClass: Class) {
        let privateDatabase = CKContainer.default().privateCloudDatabase
        
        guard let record = myClass.record else {return}
        privateDatabase.delete(withRecordID: record.recordID, completionHandler: {(recordID, error) in
            if let err = error {
                print(err)
                return
            } else {
                print("Successfully deleted:", recordID as Any)
            }
            
        })
    }
    
    // MARK: TableView methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return teacher.classes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let thisClass = teacher.classes[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "classCell")
        cell!.textLabel?.text = thisClass.name
        return cell!
    }
    
    //this is the code needed to delete a row...
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath)
    {
        // delete from cloudkit
        let myClass = teacher.classes[indexPath.row]
        deleteRecordFromCloudKit(myClass: myClass)
        
        teacher.classes.remove(at: indexPath.row)
        tableView.reloadData()
    }
    //this is the code needed to move items in the tableview
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath)
    {
        let itemToMove = teacher.classes[sourceIndexPath.row]
        teacher.classes.remove(at: sourceIndexPath.row)
        teacher.classes.insert(itemToMove, at: destinationIndexPath.row)
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        
        if segue.identifier == "toClassDetailsSegue"
        {
            teacher.currentClass = teacher.classes[tableView.indexPathForSelectedRow!.row]
            
            let nvc = segue.destination as! ClassDetailViewController
            
            if let indexPath = tableView.indexPathForSelectedRow {
                let row = indexPath.row
                teacher.currentClass = teacher.classes[row]
            }

            nvc.teacher = teacher
        }

    }
    
    
//    func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool)
//    {
//        if let controller = viewController as? ViewController
//        {
//            controller.teacher = teacher    // Here you pass the data back to your original view controller
//        }
//    }

}
