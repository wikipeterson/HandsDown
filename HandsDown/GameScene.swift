//
//  GameScene.swift
//  fortuneWheel
//
//  Created by  on 1/17/18.
//  Copyright © 2018 WikipetersonAssistStatApps. All rights reserved.
//

import SpriteKit
import GameplayKit
import AVFoundation

class GameScene: SKScene, UITableViewDelegate, UITableViewDataSource
{

    var teacher = Teacher()
    var referenceVC : ViewController!
    var screenWidth : CGFloat = 0.0
    var screenHeight: CGFloat = 0.0
    var studentArray = [Student]()
    var nameLabel = SKLabelNode()
    var wheelSprite = SKSpriteNode()
    var spinButton = SKSpriteNode()
    var tipOfArrow = SKSpriteNode()
    var tipOfArrowPoint = CGPoint()
    var angle = 0.0
    var numberOfSectors = 0
    var angleTracker : CGFloat = 0
    var rectArray = [SKSpriteNode]()
    var triangleArray = [SKShapeNode]()
    var rectLabelArray = [SKLabelNode]()
    var spinning = false
    var player = AVAudioPlayer()
    let tockSystemSoundID: SystemSoundID = 1105
    let fanfareSystemSoundID: SystemSoundID = 1103
    var holder = Student(name: "", photo: #imageLiteral(resourceName: "sampleStudentImage")) //this is for controlling the click sounds
    var loopFactor = 1 //this is for duplicating small classes on the wheel
    var synth = AVSpeechSynthesizer()
    var allowsRepeats = true
    var studentsNotPickedArray : [Student] = []
    var switchLabel = SKLabelNode()
    var titleLabel = SKLabelNode()
    var avatarNode = SKSpriteNode()
    var avatarBackgroundNode = SKSpriteNode() // this is used to change the background color of avatar
    var colorArray = [
        UIColor.blueJeansLight,
        UIColor.grassLight,
        //UIColor.aquaLight,
        //UIColor.mintLight,
        UIColor.sunFlowerLight,
        UIColor.bitterSweetLight,
        UIColor.grapefruitLight,
        UIColor.lavendarLight
    ]
    var wheelTriangleArray: [WheelTriangle] = []

    
    override func didMove(to view: SKView)
    {
        screenWidth = (self.view?.frame.width)!
        screenHeight = (self.view?.frame.height)!
        
        print("did move")
        loadStudents()
        
        setUpViews()
        
        placeSectorsOverWheel()
        addRepeatsSwitch()
        addClassButtonAndTableView()
    }
    
    func setUpViews() {
        titleLabel = childNode(withName: "titleLabel")  as! SKLabelNode
        titleLabel.fontColor = UIColor.blueJeansDark
        
        switchLabel = childNode(withName: "switchLabel") as! SKLabelNode
        switchLabel.text = "Repeats allowed"
        //switchLabel.position = CGPoint(x: screenWidth * -0.35, y: screenHeight * -0.41)
        //switchLabel.fontColor = SKColor.white
        switchLabel.fontSize = 25.0
        switchLabel.zPosition = 50
        switchLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        
        nameLabel = childNode(withName: "nameLabel") as! SKLabelNode
        nameLabel.fontColor = UIColor.mintDark
        nameLabel.fontSize = 50.0
        nameLabel.text = "???"
        
        tipOfArrow = childNode(withName: "tipOfArrow") as! SKSpriteNode
        tipOfArrow.color = UIColor.black
        tipOfArrow.colorBlendFactor = 1.0
        tipOfArrow.size = CGSize(width: 60, height: 10)
        
//        tipOfArrow.position = CGPoint(x: tipOfArrow.position.x , y: tipOfArrow.position.y)
        tipOfArrowPoint = CGPoint(x: tipOfArrow.position.x, y: tipOfArrow.position.y)
        print("tip of Arrow point: \(tipOfArrowPoint)")
        
        // place a red square at the tip of Arrow.
        
        let testNode = SKShapeNode(circleOfRadius: 5)
        testNode.fillColor = UIColor.red
        testNode.position = tipOfArrowPoint
        
        addChild(testNode)
        //set up the node that gets the wheel sectors overlayed
        wheelSprite = childNode(withName: "wheelSprite") as! SKSpriteNode
        wheelSprite.position = CGPoint(x: (scene?.frame.width)! * -0.38, y: 0)
        wheelSprite.anchorPoint = CGPoint(x: 0.5, y: 0.5  )
        wheelSprite.physicsBody?.angularDamping = 1.0
        
        avatarNode = childNode(withName: "avatarNode") as! SKSpriteNode
        avatarBackgroundNode = childNode(withName: "avatarBackgroundNode") as! SKSpriteNode
        let image = #imageLiteral(resourceName: "questionMarkImage")
        let texture = SKTexture(image: image)
        avatarNode.texture = texture
    }
    
    func loadStudents() {
        // this might not be necessary, because we error check in viewController and pass the class from there.
        let student1 = Student(name: "Bryn", photo: #imageLiteral(resourceName: "ElephantAvatar"))
        let student2 = Student(name: "Lucky", photo: #imageLiteral(resourceName: "BearAvatar"))
        let student3 = Student(name: "Cameron", photo: #imageLiteral(resourceName: "BirdAvatar"))
        let student4 = Student(name: "Steve", photo: #imageLiteral(resourceName: "DogAvatar"))
        let student5 = Student(name: "Zoey", photo: #imageLiteral(resourceName: "BearAvatar"))
        let student6 = Student(name: "Amy", photo: #imageLiteral(resourceName: "CatAvatar"))
        //get the teacher data from ViewController
        if let currentClass = teacher.currentClass {
            studentArray = currentClass.students
        } else {
            studentArray = [student1, student2, student3, student4, student5, student6]
        }
        
        studentsNotPickedArray = studentArray
    }
    
    // this is created global so that we can access it later
    lazy var classButton: UIButton = {
        let button = UIButton()
        button.setTitle("Default Class", for: UIControlState())
        button.setTitleColor(UIColor.blueJeansDark, for: UIControlState())
        button.titleLabel?.font = UIFont(name: "Helvetica Neue", size: 50.0)

        button.backgroundColor = UIColor.white
        button.layer.borderColor = UIColor.darkGray.cgColor
        button.layer.borderWidth = 3.0
//        button.layer.shadowOpacity = 0.8
//        button.layer.shadowRadius = 10.0
//        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.cornerRadius = 10.0
        button.frame = CGRect(x: 0, y: 0, width: screenWidth * 0.75, height: screenHeight * 0.1)
        button.center = CGPoint(x: screenWidth * 0.5, y: screenHeight * 0.22)
        button.addTarget(self, action: #selector(classButtonTapped(sender:)), for: .touchUpInside)
        return button
    }()
    
    lazy var classTableView: ClassTableView = {
        let rect = CGRect(x: 0, y: 0, width: screenWidth * 0.75, height: screenHeight * 0.5)
        let table = ClassTableView(frame: rect, style: UITableViewStyle.plain)
        table.center = CGPoint(x: screenWidth * 0.5, y: screenHeight * 0.54)
        table.items = teacher.classes
        // register a cell
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        table.delegate = self
        table.dataSource = self
        // this will remove extra unsed rows from tableview
        table.tableFooterView = UIView(frame: .zero)
        table.backgroundColor = UIColor.clear
        table.layer.shadowColor = UIColor.black.cgColor
        table.layer.shadowRadius = 10.0
        table.layer.shadowOpacity = 0.8
        table.layer.masksToBounds = true

        return table
    }()
    
    func addClassButtonAndTableView() {
        print("button should appear")
        self.view?.addSubview(classButton)
//        classButton.center = CGPoint(x: titleLabel.position.x, y: titleLabel.position.y + 100.0)
        self.view?.addSubview(classTableView)
        classTableView.isHidden = true
    }
    
    @objc func classButtonTapped(sender: UIButton) {
        classTableView.isHidden = false
        classTableView.reloadData()
    }
    
    // MARK: TableView Methods
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return teacher.classes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        let theClass = self.teacher.classes[indexPath.row]
        cell.layer.cornerRadius = 5.0
        cell.layer.borderColor = UIColor.darkGray.cgColor
        cell.layer.borderWidth = 2.0
        cell.layer.masksToBounds = true
        cell.textLabel?.font = UIFont(name: "Avenir Book", size: 30.0)
        cell.backgroundColor = UIColor.white
        cell.textLabel?.textColor = UIColor.mintDark
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        cell.textLabel?.textAlignment = .center
        cell.textLabel?.text = theClass.name
//        cell.backgroundColor = UIColor(displayP3Red: 0.99, green: 0.99, blue: 0.99, alpha: 1.0)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let theClass = teacher.classes[indexPath.row]
        teacher.currentClass = theClass
        updateGameScene(theClass: theClass)
        print("You selected cell #\(indexPath.row)!")
        
        wheelSprite.physicsBody?.angularVelocity = 0
        spinning = false
    }
    
    func updateGameScene(theClass: Class) {
        classButton.setTitle(theClass.name, for: UIControlState())
        
        studentArray = theClass.students
        studentsNotPickedArray = theClass.students
        removeSectorsFromWheel()
        placeSectorsOverWheel()
        classTableView.isHidden = true
    }

    @objc func switchValueDidChange(sender:UISwitch!)
    {
        allowsRepeats = !allowsRepeats
        if allowsRepeats
        {
            switchLabel.text = "Repeats allowed"
        } else
        {
            switchLabel.text = "Remove when picked"
        }
        print("switch switched")
        
    }
    
    func addRepeatsSwitch()
    {
        let repeatSwitch = UISwitch()
        repeatSwitch.center = CGPoint(x: screenWidth * 0.1, y: screenHeight * 0.9)
        repeatSwitch.isOn = false
        repeatSwitch.setOn(false, animated: true)
        repeatSwitch.addTarget(self, action: #selector(switchValueDidChange), for: .valueChanged)
        self.view?.addSubview(repeatSwitch)
        print("added a switch")
    }
    
    
    func placeSectorsOverWheel()
    {
        rectArray = []
        triangleArray = []
        rectLabelArray = []
        wheelTriangleArray = []
        
        switch studentsNotPickedArray.count
        {
            case 0:
                studentArray.append(Student(name: "empty class", photo: #imageLiteral(resourceName: "foxImage")))
                loopFactor = 9
            case 1:
                loopFactor = 9
            case 2:
                loopFactor = 5
            case 3:
                loopFactor = 4
            case 4...5:
                loopFactor = 3
            case 6...10:
                loopFactor = 2
            default:
                loopFactor = 1
        }

        let numberOfSectors = studentsNotPickedArray.count * loopFactor
        angle = 2 * Double.pi / Double(numberOfSectors)
        let theta = 2.0 * Double.pi / Double(numberOfSectors) / 2.0
        
        //set the rects, tris, and labels on wheel
        for num in 0..<Int(numberOfSectors)
        {
            let sizeFactor = 250.0
            let rect = SKSpriteNode(color: UIColor.white, size: CGSize(width: sizeFactor, height: 2 * sizeFactor * tan(theta)))
            rect.position = CGPoint(x: 0, y: 0)
            rect.zPosition = 1
            rect.anchorPoint = CGPoint(x: 0, y: 0.5)
            rect.zRotation = CGFloat(angle * Double(num))
            rectArray.append(rect)
            rect.name = "rectNode"
            wheelSprite.addChild(rect)
            
            let topEdge = CGPoint(x: sizeFactor * cos(angle / 2.0 + angle * Double(num)), y: sizeFactor * sin(angle / 2.0 + angle * Double(num)))
            let bottomEdge = CGPoint(x: sizeFactor * cos(angle * Double(num) - angle / 2.0 ), y: sizeFactor * sin(angle * Double(num) - angle / 2.0 ))
            var points = [CGPoint(x: 0, y: 0), topEdge, bottomEdge]
            //let hue = CGFloat(Double(num) / Double(numberOfSectors))
            let triangleShapeNode = SKShapeNode(points: &points, count: points.count)
            triangleShapeNode.zPosition = 5
            //triangleShapeNode.fillColor = UIColor(hue: hue, saturation: 1.0, brightness: 1.0, alpha: 1.0)
            triangleShapeNode.fillColor = colorArray[num % colorArray.count]
            triangleShapeNode.strokeColor = UIColor.darkGray
            triangleShapeNode.lineWidth = 3.0
            triangleShapeNode.name = "triangleNode"
            
            triangleArray.append(triangleShapeNode)
            wheelSprite.addChild(triangleShapeNode)
    
            
            let rectLabel = SKLabelNode(text: "")
            let currentStudent = studentsNotPickedArray[num % studentsNotPickedArray.count]
            rectLabel.text = currentStudent.name
            rectLabel.position = CGPoint(x: sizeFactor - 30.0, y: -10)
            rectLabel.fontColor = UIColor.white
            rectLabel.fontName = "HelveticaNeue"
            rectLabel.fontSize = CGFloat(20.0 + Double(loopFactor) * 2.0)
            rectLabel.zPosition = 4
            rectLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.right
            rect.addChild(rectLabel)
            rect.name = "labelNode"
            rectLabelArray.append(rectLabel)
            
            let newWheelTriangle = WheelTriangle(triangle: triangleShapeNode, label: rectLabel, student: currentStudent)
            wheelTriangleArray.append(newWheelTriangle)
        }
    }
    
    func removeSectorsFromWheel()
    {
        spinning = false
        for label in rectLabelArray
        {
            label.removeFromParent()
        }
        for tri in triangleArray
        {
            tri.removeFromParent()
        }
        for rect in rectArray
        {
            rect.removeFromParent()
        }
        for wheel in wheelTriangleArray {
            wheel.label.removeFromParent()
            wheel.triangle.removeFromParent()
        }
    }
    
//    func playSound(soundName: String)
//    {
//        let path = Bundle.main.path(forResource: soundName, ofType:nil)!
//        let url = URL(fileURLWithPath: path)
//
//        do {
//            player = try AVAudioPlayer(contentsOf: url)
//            player.play()
//        } catch {
//            // couldn't load file :(
//        }
//    }
    
    
    override func update(_ currentTime: TimeInterval) {
        if spinning {
            if let node = atPoint(tipOfArrowPoint) as? SKShapeNode {
                for i in 0..<wheelTriangleArray.count {
                    if wheelTriangleArray[i].triangle == node {
                        // we found the wheel!
                        let foundWheel = wheelTriangleArray[i]
                        let currentStudent = foundWheel.student
                        nameLabel.text = currentStudent.name
                        let image = currentStudent.photo
                        let texture = SKTexture(image: image)
                        avatarNode.texture = texture
                        avatarBackgroundNode.color = currentStudent.color
                        avatarBackgroundNode.colorBlendFactor = 1.0
                        print(currentStudent.name)
                        
                        if (wheelSprite.physicsBody?.angularVelocity)!.magnitude < CGFloat(0.01) && spinning == true {
                            // the wheel stopped!
                            print("jumped in with selectedStudent: \(currentStudent.name)")
                            wheelSprite.physicsBody?.angularVelocity = 0.01
    
                            AudioServicesPlaySystemSound(fanfareSystemSoundID)
                            AudioServicesPlaySystemSound(4095)
    
                            nameLabel.text = currentStudent.name + "!"
                            nameLabel.fontSize = 90.0
                            speak(textToSpeak: currentStudent.name)
                            if !allowsRepeats && studentsNotPickedArray.count > 1
                            {
                                studentsNotPickedArray.remove(at: i % studentsNotPickedArray.count)
                            }
                            spinning = false
                            //return
                            break
                        }
                    }
                }
            }
        }

    }
    
    // this no longer gets used.  Im just saving it to show to steve.  I changed from intersects with to node contains point of tip of the arrow.  I also had to change the z position of the triangles so that they were on top.  Nodecontains point will grab the node with the highest z position.
//    func updateChosenOne() {
//        if spinning
//        {
//            for i in 0..<(triangleArray.count)
//            {
//                if triangleArray[i].intersects(tipOfArrow)
//                {
//                    let selectedStudent = studentsNotPickedArray[i % studentsNotPickedArray.count]
//                    nameLabel.text = selectedStudent.name
//                    let image = selectedStudent.photo
//                    let texture = SKTexture(image: image)
//                    avatarNode.texture = texture
//
//                    avatarBackgroundNode.color = selectedStudent.color
//                    avatarBackgroundNode.colorBlendFactor = 1.0
//
//
//                    //                    if studentsNotPickedArray[i % studentsNotPickedArray.count].name != holder.name
//                    //                    {
//                    //                        AudioServicesPlaySystemSound(tockSystemSoundID)
//                    //                    }
//                    //                    holder = studentsNotPickedArray[i % studentsNotPickedArray.count]
//                    //
//                    if (wheelSprite.physicsBody?.angularVelocity)!.magnitude < CGFloat(0.01) && spinning == true {
//
//                        wheelSprite.physicsBody?.angularVelocity = 0
//
//                        AudioServicesPlaySystemSound(fanfareSystemSoundID)
//                        AudioServicesPlaySystemSound(4095)
//                        nameLabel.text = nameLabel.text! + "!"
//                        nameLabel.fontSize = 90.0
//                        speak(textToSpeak: nameLabel.text!)
//                        if !allowsRepeats && studentsNotPickedArray.count > 1
//                        {
//                            studentsNotPickedArray.remove(at: i % studentsNotPickedArray.count)
//                        }
//
//                        spinning = false
//                        //return
//                        break
//                    }
//                }
//            }
//        }
//    }
    
    func speak(textToSpeak: String)
    {
        print("speaking: \(textToSpeak)")
        let utterance = AVSpeechUtterance(string: textToSpeak)
        //utterance.voice = AVSpeechSynthesisVoice(language: "us-au") //choose voice
        synth.speak(utterance)
    }
    
    func resetPicks()
    {
        studentsNotPickedArray = studentArray
        placeSectorsOverWheel()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        if classTableView.isHidden == false {
            classTableView.isHidden = true
        }
        let touchLocation = touches.first?.location(in: self)
        
        if wheelSprite.frame.contains(touchLocation!)
        {
            wheelSprite.zRotation = 0
//            removeSectorsFromWheel()
//            placeSectorsOverWheel()
            let randomSpin = CGFloat(arc4random_uniform(1200)+500)
            wheelSprite.physicsBody?.applyAngularImpulse(-1.0 * CGFloat(randomSpin))
            spinning = true
            nameLabel.fontSize = 50.0
            print("begin spin")
        }
    }
    
}
