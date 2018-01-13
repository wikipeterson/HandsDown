//
//  GroupsVC.swift
//  HandsDown
//
//  Created by Christopher Walter on 1/10/18.
//  Copyright © 2018 WikipetersonAssistStatApps. All rights reserved.
//

import UIKit

class ClassesVC: UIViewController, UITableViewDataSource, UITableViewDelegate {

    
    // MARK: Outlets

    
    
    // MARK: Properties
    var classes: [Class] = [Class]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return classes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "classCell", for: indexPath)
        
        // grab the group from the array of groups that matches the cell row
        let thisClass = classes[indexPath.row]
        
        // add more here to make cell and table view look better.  
        cell.textLabel?.text = thisClass.name
        
        return cell
    }
    

   

}
