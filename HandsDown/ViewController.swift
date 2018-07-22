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
    var defaultClass: Class = Class()
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        createDefaultClass()
        screenWidth = self.view.frame.width
        screenHeight = self.view.frame.height
        
        mySKView.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight )
        mySKView.center = CGPoint(x: screenWidth / 2, y: screenHeight * 0.5)
        
        // load classes from cloudkit.  If there are no classes, a demo class will be created
        
        updateUIElements()
        setupNavBar()
        
        // check to make sure user is logged into iCloud before loading data
        tryToLoadCloudKitData()
        
        // this observer will get called from Class, after it is finished loading the students from the class Class (ps, that naming is the worst.)
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.handleStudentsLoaded), name: NSNotification.Name(rawValue: Class.studentsLoadedNotification), object: nil)
        
        // this observer is used to detect if user signs in or signs out of icloud account.  If account changes
        NotificationCenter.default.addObserver(self, selector: #selector(iCloudAccountChanged), name: NSNotification.Name.NSUbiquityIdentityDidChange, object: nil)
        loadGameScene()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateGameScene()
    }
    
    func createDefaultClass() {
        let student1 = Student(name: "Bryn", photo: #imageLiteral(resourceName: "ElephantAvatar"))
        let student2 = Student(name: "Lucky", photo: #imageLiteral(resourceName: "BearAvatar"))
        let student3 = Student(name: "Cameron", photo: #imageLiteral(resourceName: "DogAvatar"))
        let student4 = Student(name: "Steve", photo: #imageLiteral(resourceName: "BirdAvatar"))
        let student5 = Student(name: "Zoey", photo: #imageLiteral(resourceName: "CatAvatar"))
        let student6 = Student(name: "Amy", photo: #imageLiteral(resourceName: "BearAvatar"))
        let studentArray = [student1, student2, student3, student4, student5, student6]
        defaultClass = Class(name: "Default", students: studentArray)
    }
    
    
    @objc func iCloudAccountChanged() {
        tryToLoadCloudKitData()
    }
    
    func tryToLoadCloudKitData() {
        // check to make sure user is logged into iCloud before loading data
        let iCloudAvailable = isICloudContainerAvailable()
        if iCloudAvailable == true {
            loadClassesFromCloudKit()
            self.manageClassesButton.isHidden = false
        } else {
            noiCloudAlert(message: "You must be signed into iCloud in order to save and load Class data.  Go to \"Setting\" -> \"Sign in to your iPhone\".")
            teacher = Teacher()
            self.manageClassesButton.isHidden = true
        }
    }
    func noiCloudAlert(message: String) {
        let alert = UIAlertController(title: "ERROR", message: message, preferredStyle: .alert)
        let settingsAction = UIAlertAction(title: "Go to  Settings", style: .default, handler: {action in
            guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
                return
            }
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                    //                    print("Settings opened: \(success)") // Prints true
                })
            }
        })
        let returnAction = UIAlertAction(title: "Work without data", style: .default, handler: nil)
        alert.addAction(returnAction)
        alert.addAction(settingsAction)
        present(alert, animated: true, completion: nil)
    }
    
    // this is causing constraint issues... figure out later
    func setupNavBar() {
        let navBar = navigationController?.navigationBar
        let color = UIColor.mintLight
        //        let color = UIColor(red: 27.0/255.0, green: 176.0/255.0, blue: 255.0/255.0, alpha: 1.0)
        //        navBar?.backgroundColor = UIColor.gray
        navBar?.tintColor = color
        
        let font = UIFont(name: "Avenir", size: 25)
        
        navBar?.titleTextAttributes = [NSAttributedStringKey.foregroundColor: color, NSAttributedStringKey.font: font!]
        
        // do more to customize and make it look good
    }
    // this gets called from notification after classes get loaded.
    @objc func handleStudentsLoaded() {
        updateUIElements()
        updateGameScene()
    }
    
    func updateGameScene() {
        let scene = mySKView.scene as! GameScene
        scene.teacher = teacher
        if let currentClass = teacher.currentClass {
            scene.updateGameScene(theClass: currentClass)
        } else {
            scene.updateGameScene(theClass: defaultClass)
        }
    }
    
    func loadGameScene() {
        // load the spritekit view
        print("gamescene loaded")
        
        mySKView.scene?.isPaused = true
        if let view = self.mySKView
        {
            // Load the SKScene from 'GameScene.sks'
            
            //            if let scene = GameScene(fileNamed: "GameScene") {
            //                scene.teacher = teacher
            //                //scene.referenceVC = self
            //                // Set the scale mode to scale to fit the window
            //                scene.scaleMode = .aspectFill
            //                // Present the scene
            //
            //                view.presentScene(scene)
            //            }
            
            let scene = GameScene(size: view.bounds.size)
            let SKView = view
            scene.scaleMode = .aspectFill
            scene.teacher = teacher
            scene.referenceVC = self
            SKView.presentScene(scene)
            view.ignoresSiblingOrder = true
            view.showsFPS = false
            view.showsNodeCount = false
        }
    }
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
    //    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
    //        if UIDevice.current.userInterfaceIdiom == .phone {
    //            return .allButUpsideDown
    //        } else {
    //            return .all
    //        }
    //    }
    
    
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
