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
    
    @IBOutlet weak var tableView: UITableView!
    var editSwitch = true
    var teacher = Teacher()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return teacher.classes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let thisClass = teacher.classes[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "classCell")
        cell!.textLabel?.text = thisClass.name
        return cell!
    }
    
    
    @IBAction func editButtonWasTapped(_ sender: UIButton) {
        if editSwitch == true
        {
            tableView.isEditing = true
            editSwitch = false
            sender.setTitle("End Editing", for: .normal)

        }
        else
        {
            tableView.isEditing = false
            editSwitch = true
            sender.setTitle("Edit Class List", for: .normal)
        }
    }
    
    @IBAction func addButtonWasTapped(_ sender: UIButton) {

        let alert = UIAlertController(title: "Add a new class", message: nil, preferredStyle: .alert)
        alert.addTextField(configurationHandler: {textfield in textfield.placeholder = "Name of class"})
        let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
            let newClassName = alert.textFields![0].text
            let newClass = Class(name: newClassName!, students: [])
            
            self.teacher.classes.append(newClass)
            self.tableView.reloadData()
            
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
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
        teacher.currentClassID = tableView.indexPathForSelectedRow!.row
        let nvc = segue.destination as! ClassDetailViewController
        nvc.teacher = teacher
    }


}
