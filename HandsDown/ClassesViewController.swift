//
//  ClassesViewController.swift
//  HandsDown
//
//  Created by  on 1/13/18.
//  Copyright © 2018 WikipetersonAssistStatApps. All rights reserved.
//

import UIKit
import CloudKit


class ClassesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    @IBOutlet weak var currentClassLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var editSwitch = true
    var teacher = Teacher()
    

    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        loadClassesFromCloudKit()
//        CKContainer.default().fetchUserRecordID { (recordID, error) in
//            if let error = error {
//                print(error)
//            } else if let recordID = recordID {
//                print(recordID)
//            }
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadClassesFromCloudKit()
    }
    
    

    
    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
        navigationController?.dismiss(animated: true, completion: nil)
        
        // save any changes here
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
            let newClass = Class(name: newClassName, students: [Student]())
            self.saveClassToCloudKit(name: newClassName)
//             figure out how to loadClassesFromCloudKit, only after the save class has finished.
            self.loadClassesFromCloudKit()
            self.teacher.classes.append(newClass)
            self.tableView.reloadData()
            
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
        }
    }
    
    func loadClassesFromCloudKit() {
        let privateDatabase = CKContainer.default().privateCloudDatabase
        
        // Initialize Query
        // look more into Predicates.  You can query by name, distance form, etc.
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Class", predicate: predicate)
        
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
            self.teacher.classes.removeAll()
            for record in records {
                let foundClass = Class(record: record) // create a class from the record
                // append to classes array
                self.teacher.classes.append(foundClass)
            }
            // this will prevent crash because we are working on a background thread.  We might not need this, but it was needed for async calls in firebase
            DispatchQueue.main.async(execute: {
                print("we reloaded the table")
                self.tableView.reloadData()
            })
        }
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
        
        if segue.identifier == "toClassDetailsSegue" {
            teacher.currentClassID = tableView.indexPathForSelectedRow!.row
            let nvc = segue.destination as! ClassDetailViewController
            
            if let indexPath = tableView.indexPathForSelectedRow {
                let row = indexPath.row
            
                let selectedClass = teacher.classes[row]
                nvc.myClass = selectedClass
            }

            nvc.teacher = teacher
        }
        
        
    }
    
    func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool)
    {
        if let controller = viewController as? ViewController
        {
            controller.teacher = teacher    // Here you pass the data back to your original view controller
        }
    }

}
