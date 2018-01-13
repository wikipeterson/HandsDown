//
//  itemsVC.swift
//  HandsDown
//
//  Created by Christopher Walter on 1/10/18.
//  Copyright © 2018 WikipetersonAssistStatApps. All rights reserved.
//

import UIKit

class studentsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // Mark: outlets
    @IBOutlet weak var titleTextField: UITextField!
    
    @IBOutlet weak var itemsTableView: UITableView!
    @IBOutlet weak var editButton: UIBarButtonItem!
    // Mark: Properties
    var group: Group?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }


    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
    }
    
    @IBAction func editButtonTapped(_ sender: UIBarButtonItem) {
    }
    
    // MARK: TableviewMethods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let myGroup = group {
            return myGroup.items.count
        } else {
            print("Couldn't find group on ItemVC")
            return 0
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath)
        
        if let myItem = group?.items[indexPath.row] {
            cell.textLabel?.text = myItem.name
        }
        
        
        return cell
    }

}
