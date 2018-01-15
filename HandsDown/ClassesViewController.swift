//
//  ClassesViewController.swift
//  HandsDown
//
//  Created by  on 1/13/18.
//  Copyright © 2018 WikipetersonAssistStatApps. All rights reserved.
//

import UIKit

class ClassesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    @IBOutlet weak var currentClassLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var editSwitch = true
    var teacher = Teacher()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
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
            let newClass = Class(name: newClassName, students: [])
            
            self.teacher.classes.append(newClass)
            self.tableView.reloadData()
            
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
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
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
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


}
