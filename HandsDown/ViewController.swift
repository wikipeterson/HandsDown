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

class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, SetTeacherDelegate {
    
  
    @IBOutlet weak var mySKView: SKView!
    @IBOutlet weak var classNameLabel: UILabel!
    @IBOutlet weak var studentNameLabel: UILabel!
    @IBOutlet weak var myImageView: UIImageView!
    @IBOutlet weak var myPickerView: UIPickerView!
    @IBOutlet weak var shuffleButton: UIButton!
    @IBOutlet weak var myStackView: UIStackView!
    @IBOutlet weak var manageClassesButton: UIButton!
    @IBOutlet weak var manageGroupsButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    
    
    var teacher = Teacher()
    var screenWidth : CGFloat = 0.0
    var screenHeight: CGFloat = 0.0
    var myFont = "Helvetica Neue"
    var player : AVAudioPlayer!
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        myPickerView.dataSource = self
        myPickerView.delegate = self
        

        // load classes from cloudkit.  If there are no classes, a demo class will be created
        loadClassesFromCloudKit()
        
        updateUIElements()
        
        // this observer will get called from Class, after it is finished loading the students from the class Class (ps, that naming is the worst.)
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.handleStudentsLoaded), name: NSNotification.Name(rawValue: Class.studentsLoadedNotification), object: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateUIElements()
        myPickerView.reloadAllComponents()
    }
    
    // this gets called from notifacation after classes get loaded.
    @objc func handleStudentsLoaded() {
        updateUIElements()
        attemptReloadOfPickerView()
        
    }
    
    func loadGameScene() {
        // load the spritekit view
        if let view = self.mySKView
        {
            // Load the SKScene from 'GameScene.sks'
            //  if let scene = SKScene(fileNamed: "GameScene") {
            if let scene = GameScene(fileNamed: "GameScene") {
                scene.teacher = teacher
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                // Present the scene
                //                scene.userData = NSMutableDictionary()
                //                scene.userData?.setObject(teacher, forKey: "The Teacher" as NSCopying)
                view.presentScene(scene)
            }
            view.ignoresSiblingOrder = true
            view.showsFPS = false
            view.showsNodeCount = false
            
        }
    }
    // timer is used when data.  It is a work around so that we are not reloading the pickerView over and over again after each class gets students loaded, and we only reload the pickerview once.
    
    fileprivate func attemptReloadOfPickerView() {
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadPickerView), userInfo: nil, repeats: false)
    }
    var timer: Timer?
    
    @objc func handleReloadPickerView() {
        print("pickerView is reloaded")
        self.myPickerView.reloadAllComponents()
        loadGameScene()
        
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
                self.createDemoClass()
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
                    self.createDemoClass()
                }
                
                // everything is reloaded from notifcation observer that will be called after classes get loaded with the students.
            }
        }
    }
    
    
    func createDemoClass() {
        //create demo class
        let student1 = Student(name: "Bryn", picture: #imageLiteral(resourceName: "foxImage"))
        let student2 = Student(name: "Lucky", picture: #imageLiteral(resourceName: "beeImage"))
        let student3 = Student(name: "Cameron", picture: #imageLiteral(resourceName: "pigTailGirl"))
        let student4 = Student(name: "Steve", picture: #imageLiteral(resourceName: "Screen Shot 2018-01-03 at 8.59.44 AM"))
        let student5 = Student(name: "Zoey", picture: #imageLiteral(resourceName: "elmoImage"))
        let student6 = Student(name: "Amy", picture: #imageLiteral(resourceName: "sampleStudentImage"))
        
        //make the demo class be classID 0 for teacher class
        let demoClass = Class()
        demoClass.students = [student1, student2, student3, student4, student5, student6]
        demoClass.name = "Demo Class"
        demoClass.shuffle() // randomize order of students
        teacher.classes.append(demoClass)
        
        // set currentClass to demoClass
        teacher.currentClass = demoClass
        
        // figure out how to save demo class to cloudkit, so that it will always appear if no classes are available.
        
        // figure out how to reload pickerview and data on page
        updateUIElements()
        myPickerView.reloadAllComponents()
    }

    func updateUIElements() {
        
        //Place UI elements
        screenWidth = self.view.frame.width
        screenHeight = self.view.frame.height
        
        studentNameLabel.text = "?"
        studentNameLabel.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight * 0.18)
        studentNameLabel.center = CGPoint(x: screenWidth / 2, y: screenHeight * 0.2)
        studentNameLabel.font = UIFont(name: myFont, size: screenHeight / 10)
        
        myImageView.frame = CGRect(x: 0, y: 0, width: screenWidth * 0.4, height: screenHeight * 0.4)
        myImageView.center = CGPoint(x: screenWidth / 4, y: screenHeight * 0.5)
        
        myPickerView.frame = CGRect(x: 0, y: 0, width: screenWidth * 0.4, height: screenHeight * 0.6)
        myPickerView.center = CGPoint(x: screenWidth * 3/4, y: screenHeight * 0.5)
        
        shuffleButton.frame = CGRect(x: 0, y: 0, width: screenWidth , height: screenHeight * 0.18)
        shuffleButton.center = CGPoint(x: screenWidth / 2, y: screenHeight * 0.84)
        
        myStackView.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight * 0.06)
        myStackView.center = CGPoint(x: screenWidth / 2, y: screenHeight * 0.97)
        
        manageClassesButton.titleLabel?.font = UIFont(name: myFont, size: screenHeight / 25)
        manageGroupsButton.titleLabel?.font = UIFont(name: myFont, size: screenHeight / 25)
        settingsButton.titleLabel?.font = UIFont(name: myFont, size: screenHeight / 25)
        
        // set a random starting point on PickerView
        guard let currentClass = teacher.currentClass else {return}
        let randomStaringRow = Int(arc4random_uniform(1000)) + currentClass.students.count
        myPickerView.selectRow(randomStaringRow, inComponent:0, animated:true)
        
        classNameLabel.text = currentClass.name
        classNameLabel.font = UIFont(name: myFont, size: screenHeight / 24)
        classNameLabel.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight * 0.05)
        classNameLabel.center = CGPoint(x: screenWidth / 2, y: screenHeight * 0.12)
    }
    @IBAction func shuffleButtonTapped(_ sender: UIButton)
    {
        guard let currentClass = teacher.currentClass else {return}
        let randomPickerViewRow = Int(arc4random_uniform(UInt32(1000 * currentClass.students.count)))
        
        myPickerView.selectRow(randomPickerViewRow, inComponent:0, animated:true)
        setStudent(row: randomPickerViewRow)
    }
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if let currentClass = teacher.currentClass {
            return 1000 * currentClass.students.count
        } else {
            return 0
        }
    }
    
    
    //MARK: Delegates
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if let currentClass = teacher.currentClass {
            return currentClass.students[row % currentClass.students.count].name
        } else {
            return "Error"
        }
        
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        setStudent(row: row)
        
    }
    
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var pickerLabel = view as! UILabel!
        if view == nil {  //if no label there yet
            pickerLabel = UILabel()
            //color the label's background
            let hue = CGFloat(0.6)
            //let hue = CGFloat(row)/CGFloat(teacher.classes[teacher.currentClassID].students.count)
            pickerLabel?.backgroundColor = UIColor(hue: hue, saturation: 1.0, brightness: 1.0, alpha: 1.0)
        }
        var titleData = ""
        if let currentClass = teacher.currentClass {
            titleData = currentClass.students[row % currentClass.students.count].name
        }
        let myTitle = NSAttributedString(string: titleData, attributes: [NSAttributedStringKey.font:UIFont(name: myFont, size: screenHeight / 24)!,NSAttributedStringKey.foregroundColor:UIColor.black])
        pickerLabel!.attributedText = myTitle
        pickerLabel!.textAlignment = .center
        
        return pickerLabel!
        
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 50.0
    }
    
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return myPickerView.frame.width
    }
    
    func setStudent(row: Int)
    {
        guard let currentClass = teacher.currentClass else {return}
        if row > 0 {
            let currentStudent = currentClass.students[row % currentClass.students.count]
            studentNameLabel.text = currentStudent.name + "!"
            myImageView.image = currentStudent.picture
            playSound(soundName: "clickSound.mp3")
        }
        else {
            print("There are no students, therefore cannot play this game")
        }
        
    }
    

    
    //I want the question marks to show up when the wheel starts to spin, but it only does that when I touch anything but the picker or button
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        studentNameLabel.text = "?"
        myImageView.image = #imageLiteral(resourceName: "questionMarkImage")
        print("touched")
    }
    
    //tried the same with a swipe recongizer on picker to no avail
   @IBAction func swipeGestureOnPicker(_ sender: UISwipeGestureRecognizer) {
        
        studentNameLabel.text = "?"
        myImageView.image = #imageLiteral(resourceName: "questionMarkImage")
        print("swiped")
    }
    
    
    //set up function for playing sounds
    func playSound(soundName: String)
    {
        let path = Bundle.main.path(forResource: soundName, ofType:nil)!
        let url = URL(fileURLWithPath: path)
        
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player.play()
        } catch {
            // couldn't load file :(
        }
        
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



    

    



