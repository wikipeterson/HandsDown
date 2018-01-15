//
//  ClassDetailViewController.swift
//  HandsDown
//
//  Created by  on 1/14/18.
//  Copyright © 2018 WikipetersonAssistStatApps. All rights reserved.
//

import UIKit

class ClassDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var NameTextField: UITextField!
    @IBOutlet weak var myTableView: UITableView!
    var editSwitch = true
    var teacher = Teacher()
    var myClass: Class?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
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
        
        // figure out how to save things here
    }
    @IBAction func addStudentButtonTapped(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Add a student", message: nil, preferredStyle: .alert)
        alert.addTextField(configurationHandler: {textfield in textfield.placeholder = "Name"})
        
        let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
            let newName = alert.textFields![0].text
            let newStudent = Student(name: newName!, picture: #imageLiteral(resourceName: "questionMarkImage"))
            //    self.teacher.classes[self.teacher.currentClassID].students.append(newStudent)
            self.myClass?.students.append(newStudent)
            self.myTableView.reloadData()
            
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
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

}