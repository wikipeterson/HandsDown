//
//  ClassDetailViewController.swift
//  HandsDown
//
//  Created by  on 1/14/18.
//  Copyright © 2018 WikipetersonAssistStatApps. All rights reserved.
//

import UIKit

class ClassDetailViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var editSwitch = true
    var teacher = Teacher()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }

    @IBAction func editButtonTapped(_ sender: UIButton)
    {
        if editSwitch == true
        {
            tableView.isEditing = true
            editSwitch = false
            sender.setTitle("Done", for: .normal)
        }
        else
        {
            tableView.isEditing = false
            editSwitch = true
            sender.setTitle("Edit", for: .normal)
        }
    }
    
    @IBAction func addStudentButtonTapped(_ sender: UIButton) {
    
        let alert = UIAlertController(title: "Add a student", message: nil, preferredStyle: .alert)
        alert.addTextField(configurationHandler: {textfield in textfield.placeholder = "Name"})
        
        let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                let newName = alert.textFields![0].text
                let newStudent = Student(name: newName!, picture: #imageLiteral(resourceName: "questionMarkImage"))
    self.teacher.classes[self.teacher.currentClassID].students.append(newStudent)
                self.tableView.reloadData()

        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return teacher.classes[teacher.currentClassID].students.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let student = teacher.classes[teacher.currentClassID].students[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "studentCell")
        cell?.textLabel?.text = student.name
        return cell!
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
