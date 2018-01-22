//
//  ViewController.swift
//  HandsDown
//
//  Created by  on 1/9/18.
//  Copyright © 2018 WikipetersonAssistStatApps. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
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
        
        playSound(soundName: "Captain UnderpantsSound.mp3")
        //create demo class
        let student1 = Student(name: "Bryn", picture: #imageLiteral(resourceName: "foxImage"))
        let student2 = Student(name: "Lucky", picture: #imageLiteral(resourceName: "beeImage"))
        let student3 = Student(name: "Cameron", picture: #imageLiteral(resourceName: "pigTailGirl"))
        let student4 = Student(name: "Steve", picture: #imageLiteral(resourceName: "Screen Shot 2018-01-03 at 8.59.44 AM"))
        let student5 = Student(name: "Zoey", picture: #imageLiteral(resourceName: "elmoImage"))
        let student6 = Student(name: "Amy", picture: #imageLiteral(resourceName: "sampleStudentImage"))
        
        //make the demo class be classID 0 for teacher class
        var demoClass = Class()
        demoClass.students = [student1, student2, student3, student4, student5, student6]
        demoClass.name = "Demo Class"
        demoClass.shuffle() // randomize order of students
        teacher.classes.append(demoClass)
        
        teacher.currentClass = demoClass

       
    
        // set a random starting point on PickerView
        let randomStaringRow = Int(arc4random_uniform(1000)) + teacher.classes[teacher.currentClassID].students.count
        myPickerView.selectRow(randomStaringRow, inComponent:0, animated:true)
        
        //Place UI elements
        
        screenWidth = self.view.frame.width
        screenHeight = self.view.frame.height
        
        
        classNameLabel.text = teacher.classes[teacher.currentClassID].name
        classNameLabel.font = UIFont(name: myFont, size: screenHeight / 24)
        classNameLabel.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight * 0.05)
        classNameLabel.center = CGPoint(x: screenWidth / 2, y: screenHeight * 0.12)
        
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
    }
    
    
    @IBAction func shuffleButtonTapped(_ sender: UIButton)
    {
        let randomPickerViewRow = Int(arc4random_uniform(UInt32(1000 * teacher.classes[teacher.currentClassID].students.count)))
        
        myPickerView.selectRow(randomPickerViewRow, inComponent:0, animated:true)
        setStudent(row: randomPickerViewRow)
    }
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 1000 * teacher.classes[teacher.currentClassID].students.count
    }
    
    
    //MARK: Delegates
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return teacher.classes[teacher.currentClassID].students[row % teacher.classes[teacher.currentClassID].students.count].name
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
        let titleData = teacher.classes[teacher.currentClassID].students[row % teacher.classes[teacher.currentClassID].students.count].name
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
        studentNameLabel.text = teacher.classes[teacher.currentClassID].students[row % teacher.classes[teacher.currentClassID].students.count].name + "!"
        myImageView.image = teacher.classes[teacher.currentClassID].students[row % teacher.classes[teacher.currentClassID].students.count].picture
        playSound(soundName: "clickSound.mp3")
    }
    

    
    //I want the question marks to show up when the wheel starts t0 spin, but it only does that when I touch anything but the picker or button
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
    
    //send the data through segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "classesSegue"
        {
            let nvc = (segue.destination as? ClassesViewController)!
            nvc.teacher = teacher
        }
        
    }
}



    

    



