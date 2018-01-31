//
//  ViewController.swift
//  HandsDown
//
//  Created by  on 1/9/18.
//  Copyright © 2018 WikipetersonAssistStatApps. All rights reserved.
//

import UIKit
import AVFoundation
import CloudKit
import SpriteKit

class ViewController: UIViewController, SetTeacherDelegate {
    
    @IBOutlet weak var mySKView: SKView!
    @IBOutlet weak var myStackView: UIStackView!
    @IBOutlet weak var manageClassesButton: UIButton!
    @IBOutlet weak var manageGroupsButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    
    
    var teacher = Teacher()
    var screenWidth : CGFloat = 0.0
    var screenHeight: CGFloat = 0.0
    var myFont = "Helvetica Neue"
    var player : AVAudioPlayer!
    var allowsRepeats = true
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        screenWidth = self.view.frame.width
        screenHeight = self.view.frame.height
        
        mySKView.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight )
        mySKView.center = CGPoint(x: screenWidth / 2, y: screenHeight * 0.5)
        
        // load classes from cloudkit.  If there are no classes, a demo class will be created
        loadClassesFromCloudKit()
        updateUIElements()
        
        // this observer will get called from Class, after it is finished loading the students from the class Class (ps, that naming is the worst.)
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.handleStudentsLoaded), name: NSNotification.Name(rawValue: Class.studentsLoadedNotification), object: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadGameScene()
    }
    
    
    // this gets called from notification after classes get loaded.
    @objc func handleStudentsLoaded() {
        updateUIElements()

        
    }
    
    func loadGameScene() {
        // load the spritekit view
        if let view = self.mySKView
        {
            // Load the SKScene from 'GameScene.sks'
            
            if let scene = GameScene(fileNamed: "GameScene") {
                scene.teacher = teacher
                //scene.referenceVC = self
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                // Present the scene
                
                view.presentScene(scene)
            }
            view.ignoresSiblingOrder = true
            view.showsFPS = false
            view.showsNodeCount = false
            
        }
    }
    // timer is used when data.  It is a work around so that we are not reloading the pickerView over and over again after each class gets students loaded, and we only reload the pickerview once.
    
//    fileprivate func attemptReloadOfPickerView() {
//        self.timer?.invalidate()
//        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadPickerView), userInfo: nil, repeats: false)
//    }
//    var timer: Timer?
    
//    @objc func handleReloadPickerView() {
//        print("pickerView is reloaded")
//        self.myPickerView.reloadAllComponents()
//        loadGameScene()
//        
//    }

    func loadClassesFromCloudKit() {
        let privateDatabase = CKContainer.default().privateCloudDatabase
        
        // Initialize Query.  And load all classes.
        let predicate = NSPredicate(value: true) // this will grab all classes
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
            // if there are no records, load demo class
            if records.count == 0 {
                //self.createDemoClass()
            } else {
//                // clear classes. then reload
//                self.teacher.classes.removeAll()
                for record in records {
                    // create a class from the record...  This will also load the students for each class.
                    let foundClass = Class(record: record)
                    self.teacher.classes.append(foundClass)
                }
                if self.teacher.classes.count > 0 {
                    self.teacher.currentClass = self.teacher.classes[0]
                } else {
                    //self.createDemoClass()
                }
                
                // everything is reloaded from notifcation observer that will be called after classes get loaded with the students.
            }
        }
    }
    
    

    func updateUIElements() {
        
        //Place UI elements
       
        
        myStackView.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight * 0.06)
        myStackView.center = CGPoint(x: screenWidth / 2, y: screenHeight * 0.97)
        
        manageClassesButton.titleLabel?.font = UIFont(name: myFont, size: screenHeight / 25)
        manageGroupsButton.titleLabel?.font = UIFont(name: myFont, size: screenHeight / 25)
        settingsButton.titleLabel?.font = UIFont(name: myFont, size: screenHeight / 25)
        
        //hide groups button until we add functionality
        manageGroupsButton.isEnabled = false
        manageGroupsButton.isHidden = true
        settingsButton.isEnabled = false
        settingsButton.isHidden = true
        

    }
    
  
    override var shouldAutorotate: Bool {
        return false
    }
    
    
    // change these orientation options
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // delegate method used to pass teacher back from classesVC
    func setTeacher(teacher: Teacher)
    {
        self.teacher = teacher
    }
    
    //send the data through segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "classesSegue"
        {
            let nvc = (segue.destination as? ClassesViewController)!
            
            nvc.teacher = teacher
            nvc.delegate = self
        }
        
    }
}



    

    



