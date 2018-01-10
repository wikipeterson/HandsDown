//
//  GroupsVC.swift
//  HandsDown
//
//  Created by Christopher Walter on 1/10/18.
//  Copyright © 2018 WikipetersonAssistStatApps. All rights reserved.
//

import UIKit

class GroupsVC: UIViewController, UITableViewDataSource, UITableViewDelegate {

    
    // MARK: Outlets
    @IBOutlet weak var groupsTableView: UITableView!
    
    // MARK: Properties
    var groups: [Group] = [Group]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groups.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "groupCell", for: indexPath)
        
        // grab the group from the array of groups that matches the cell row
        let group = groups[indexPath.row]
        
        // add more here to make cell and table view look better.  
        cell.textLabel?.text = group.name
        
        return cell
    }
    

   

}
