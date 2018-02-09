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

class ClassesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, updateTeacherDelegate
{
    // MARK: Outlets
    @IBOutlet weak var currentClassLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var tableViewNavBar: UINavigationBar!
    
    // MARK:  Properties
    var editSwitch = true
    var teacher = Teacher()
    var delegate:SetTeacherDelegate?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        // this will remove extra unsed rows from tableview
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.backgroundColor = UIColor.clear
        setUpNavBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        reloadViews()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // save any changes here
        delegate?.setTeacher(teacher: teacher)
    }
    
    func reloadViews() {
        if let currentClass = teacher.currentClass {
            currentClassLabel.text = currentClass.name
        }
        tableView.reloadData()
    }
    
    func setUpNavBar () {
        tableViewNavBar.backgroundColor = UIColor.gray
        tableViewNavBar.tintColor = UIColor.white
        tableViewNavBar.layer.cornerRadius = 4.0
        
        let font = UIFont(name: "Avenir", size: 25)
        let color = UIColor.hDLightBlueColor
//        let color = UIColor(red: 27.0/255.0, green: 176.0/255.0, blue: 255.0/255.0, alpha: 1.0)
        tableViewNavBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: color, NSAttributedStringKey.font: font!]
        
        // do more to customize and make it look good
    }
    
    @IBAction func editButtonWasTapped(_ sender: UIBarButtonItem) {
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
    
    func deleteRecordFromCloudKit(myClass: Class) {
        let privateDatabase = CKContainer.default().privateCloudDatabase
        
        guard let record = myClass.record else {return}
        privateDatabase.delete(withRecordID: record.recordID, completionHandler: {(recordID, error) in
            if let err = error {
                print(err)
                return
            } else {
//                print("Successfully deleted:", recordID as Any)
                // students will be deleted as well because of delete rule created and reference made
            }
        })
    }
    // MARK: TableView methods
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90.0
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return teacher.classes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "classCell") as! ClassesTableViewCell
        let thisClass = teacher.classes[indexPath.row]
        cell.theClass = thisClass // properties of cell will be set up in didSet Method in ClassesTVC
        cell.numberLabel.text = "\(indexPath.row + 1)"

        // set current class to selected state... Find a better way to do this
//        if thisClass.recordID == teacher.currentClass?.recordID {
//            self.tableView.selectRow(at: indexPath, animated: true, scrollPosition: .middle)
//        }
        return cell
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
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let itemToMove = teacher.classes[sourceIndexPath.row]
        teacher.classes.remove(at: sourceIndexPath.row)
        teacher.classes.insert(itemToMove, at: destinationIndexPath.row)
        tableView.reloadData()
    }
    
    // MARK:  AddClassDelegate Methods
    // this is how data gets passed back
    func updateTeacher(teacher: Teacher) {
        self.teacher = teacher
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "editClassSegue"
        {
            teacher.currentClass = teacher.classes[tableView.indexPathForSelectedRow!.row]
            
            let nvc = segue.destination as! ClassDetailViewController
            
            if let indexPath = tableView.indexPathForSelectedRow {
                let row = indexPath.row
                teacher.currentClass = teacher.classes[row]
                nvc.currentClass = teacher.classes[row]
            }
            nvc.teacher = teacher
            nvc.delegate = self
        }
        if segue.identifier == "addClassSegue" {
            let nvc = segue.destination as! ClassDetailViewController
            
            nvc.teacher = teacher
            nvc.delegate = self
            nvc.currentClass = nil
        }
    }

}
