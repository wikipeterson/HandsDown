//
//  ClassTableView.swift
//  HandsDown
//
//  Created by Christopher Walter on 2/11/18.
//  Copyright © 2018 WikipetersonAssistStatApps. All rights reserved.
//

import UIKit


// this is used to display classes in a dropdown menu from main SKView
class ClassTableView: UITableView, UITableViewDelegate, UITableViewDataSource {

    var items: [Class] = [Class]()
    var selectedClass: Class?
    
    override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
        self.delegate = self
        self.dataSource = self
        
        // this should remove extra rows and make a clear background
        self.tableFooterView = UIView(frame: .zero)
        self.backgroundColor = UIColor.clear
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell")! as UITableViewCell
        //let theClass = self.items[indexPath.row]
//        cell.textLabel?.text = theClass.name
        return cell
    }
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        return "Pick a Class"
//    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let theClass = items[indexPath.row]
        selectedClass = theClass
        
        self.isHidden = true
        print("You selected cell #\(indexPath.row)!")
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
