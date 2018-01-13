//
//  ViewController.swift
//  HandsDown
//
//  Created by  on 1/9/18.
//  Copyright © 2018 WikipetersonAssistStatApps. All rights reserved.
//

import UIKit

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
    
    let pickerData = ["Cindy", "Jan", "Marsha", "Bobby", "Peter", "Greg"]
    var screenWidth : CGFloat = 0.0
    var screenHeight: CGFloat = 0.0
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        myPickerView.dataSource = self
        myPickerView.delegate = self
        
        // set a random starting point on PickerView
        let randomStaringRow = Int(arc4random_uniform(1000)) + pickerData.count
        myPickerView.selectRow(randomStaringRow, inComponent:0, animated:true)
        
        //Place UI elements
        
        screenWidth = self.view.frame.width
        screenHeight = self.view.frame.height
        
        
        classNameLabel.text = "Demo Class"
        classNameLabel.font = UIFont(name: classNameLabel.font.fontName, size: screenHeight / 24)
        classNameLabel.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight * 0.05)
        classNameLabel.center = CGPoint(x: screenWidth / 2, y: screenHeight * 0.12)
        
        studentNameLabel.text = "?"
        studentNameLabel.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight * 0.18)
        studentNameLabel.center = CGPoint(x: screenWidth / 2, y: screenHeight * 0.2)
        studentNameLabel.font = UIFont(name: studentNameLabel.font.fontName, size: screenHeight / 10)
        
        myImageView.frame = CGRect(x: 0, y: 0, width: screenWidth * 0.4, height: screenHeight * 0.4)
        myImageView.center = CGPoint(x: screenWidth / 4, y: screenHeight * 0.5)
        
        myPickerView.frame = CGRect(x: 0, y: 0, width: screenWidth * 0.4, height: screenHeight * 0.6)
        myPickerView.center = CGPoint(x: screenWidth * 3/4, y: screenHeight * 0.5)
        
        shuffleButton.frame = CGRect(x: 0, y: 0, width: screenWidth / 2, height: screenHeight * 0.15)
        shuffleButton.center = CGPoint(x: screenWidth / 2, y: screenHeight * 0.85)
        
        
        myStackView.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight * 0.06)
        myStackView.center = CGPoint(x: screenWidth / 2, y: screenHeight * 0.97)
        
        manageClassesButton.titleLabel?.font = UIFont(name: manageClassesButton.titleLabel!.font.fontName, size: screenHeight / 25)
        manageGroupsButton.titleLabel?.font = UIFont(name: manageClassesButton.titleLabel!.font.fontName, size: screenHeight / 25)
        settingsButton.titleLabel?.font = UIFont(name: manageClassesButton.titleLabel!.font.fontName, size: screenHeight / 25)
    }
    
    
    @IBAction func shuffleButtonTapped(_ sender: UIButton)
    {
        let randomPickerViewRow = arc4random_uniform(UInt32(1000 * pickerData.count))
        
        myPickerView.selectRow(Int(randomPickerViewRow), inComponent:0, animated:true)
        studentNameLabel.text = pickerData[Int(randomPickerViewRow) % pickerData.count]
    }
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 1000 * pickerData.count
    }
    
    
    //MARK: Delegates
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row % pickerData.count]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        studentNameLabel.text = pickerData[row % pickerData.count] + "!"
    }
    
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var pickerLabel = view as! UILabel!
        if view == nil {  //if no label there yet
            pickerLabel = UILabel()
            //color the label's background
            let hue = CGFloat(row)/CGFloat(pickerData.count)
            pickerLabel?.backgroundColor = UIColor(hue: hue, saturation: 1.0, brightness: 1.0, alpha: 1.0)
        }
        let titleData = pickerData[row % pickerData.count]
        let myTitle = NSAttributedString(string: titleData, attributes: [NSAttributedStringKey.font:UIFont(name: "Chalkboard SE", size: screenHeight / 24)!,NSAttributedStringKey.foregroundColor:UIColor.black])
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
    
    
    
}



    

    



