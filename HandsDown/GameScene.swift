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

class GameScene: SKScene, SKPhysicsContactDelegate, UITableViewDataSource, UITableViewDelegate
{
    var teacher = Teacher()
    var referenceVC : ViewController!
    var screenWidth : CGFloat = 0.0
    var screenHeight: CGFloat = 0.0
    var studentArray = [Student]()
    var nameLabel = SKLabelNode()
    var tipOfFlapper = CGPoint(x: 0, y: 0)
    var wheelSprite = SKShapeNode()
    var angle = 0.0
    var numberOfSectors = 0
    var angleTracker : CGFloat = 0
    var triangleArray = [SKShapeNode]()
    var nameArray = [String]()
    var spinning = false
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
    var tickSound : SKAction!
    let pegCategory: UInt32 = 0x1 << 1
    let flapperCategory: UInt32 = 0x1 << 2
    let ignoreCategory: UInt32 = 0x1 << 3
    
    override func didMove(to view: SKView)
    {
        //screenWidth = (self.view?.frame.width)!
        //screenHeight = (self.view?.frame.height)!
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        screenWidth = (self.size.width)
        screenHeight = (self.size.height)
        backgroundColor = UIColor.white
        print("did move")
        loadStudents()
        setUpViews()
        createWheel()
        //addRepeatsSwitch()
        makeFlapper()
        addClassButtonAndTableView()
        tickSound = SKAction.playSoundFileNamed("Tick.mp3", waitForCompletion: true)
        physicsWorld.contactDelegate = self
    }
    
    func setUpViews() {
        let image = #imageLiteral(resourceName: "questionMarkImage")
        let texture = SKTexture(image: image)
        
        //        CGSize(width: size.width/2, height: (size.width/2)*2)
        let avatarSize = CGSize(width: size.width/2.5, height: size.width/4*3)
        avatarNode = SKSpriteNode(texture: texture)
        avatarNode.size = avatarSize
        
        avatarNode.position = CGPoint(x: size.width/4, y: 0)
        addChild(avatarNode)
        avatarBackgroundNode = SKSpriteNode(color: UIColor.clear, size: avatarSize)
        avatarBackgroundNode.position = avatarNode.position
        addChild(avatarBackgroundNode)
        
        // create label node
        nameLabel = SKLabelNode(text: "???")
        nameLabel.name = "nameLabel"
        nameLabel.fontColor = UIColor.mintDark
        nameLabel.fontSize = size.height / 10.0
        nameLabel.zPosition = 12
        nameLabel.fontName = "Avenir Medium"
        nameLabel.position = CGPoint(x: 0, y: size.height / -2.0 + 100)
        self.addChild(nameLabel)
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
        button.titleLabel?.font = UIFont(name: "Helvetica Neue", size: size.height / 10)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.backgroundColor = UIColor.white
        button.layer.borderColor = UIColor.darkGray.cgColor
        button.layer.borderWidth = 3.0
        button.layer.cornerRadius = 10.0
        button.frame = CGRect(x: 0, y: 0, width: screenWidth * 0.75, height: screenHeight * 0.1)
        button.center = CGPoint(x: screenWidth * 0.5, y: screenHeight * 0.14)
        button.addTarget(self, action: #selector(classButtonTapped(sender:)), for: .touchUpInside)
        return button
    }()
    
    lazy var classTableView: ClassTableView = {
        let rect = CGRect(x: 0, y: 0, width: screenWidth * 0.75, height: screenHeight * 0.5)
        let table = ClassTableView(frame: rect, style: UITableViewStyle.plain)
        table.center = CGPoint(x: screenWidth * 0.5, y: screenHeight * 0.45)
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

        self.view?.addSubview(classButton)
        //classButton.center = CGPoint(x: titleLabel.position.x, y: titleLabel.position.y + 100.0)
        self.view?.addSubview(classTableView)
        classTableView.isHidden = true
    }
    
    @objc func classButtonTapped(sender: UIButton) {
        classTableView.isHidden = false
        classTableView.reloadData()
    }
    
    // MARK: TableView Methods
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return size.height / 10
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
        cell.textLabel?.font = UIFont(name: "Avenir Book", size: size.height/20.0)
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
        removeWheel()
        createWheel()
        //        placeSectorsOverWheel()
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
    
    func makeFlapper()
    {
        let flapperTexture = SKTexture(imageNamed: "flapper")
        let flapper = SKSpriteNode(texture: flapperTexture, size: flapperTexture.size())
        addChild(flapper)
        flapper.name = "Flapper"
        print("size is \(size)")

        let flapperWidth = size.width / 5
        flapper.size = CGSize(width: flapperWidth, height: flapperWidth/2)


        flapper.position = CGPoint(x: wheelSprite.position.x + size.width/2 + size.width / 20, y: 0)

//        flapper.position = CGPoint(x: wheelSprite.position.x + size.width/2 + 18, y: 0)
        flapper.zPosition = 12
        flapper.physicsBody = SKPhysicsBody(texture: flapperTexture, size: flapper.size)
        flapper.physicsBody?.isDynamic = true
        flapper.physicsBody?.allowsRotation = true
        flapper.physicsBody?.angularDamping = 1
        //flapper.physicsBody?.friction = 100
        flapper.physicsBody?.pinned = true
        flapper.physicsBody?.affectedByGravity = false
        flapper.physicsBody?.categoryBitMask = flapperCategory
        flapper.physicsBody?.collisionBitMask = pegCategory
        flapper.physicsBody?.contactTestBitMask = pegCategory
        
        //make the flapper springy
        let fixedPoint = SKSpriteNode(color: UIColor.blue, size: CGSize(width: 10, height: 10))
        fixedPoint.position = CGPoint(x: -size.width - 15, y: 0)
        fixedPoint.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 10, height: 10))
        fixedPoint.zPosition = 15
        fixedPoint.physicsBody?.allowsRotation = true
        fixedPoint.physicsBody?.isDynamic = false
        fixedPoint.physicsBody?.affectedByGravity = false
        addChild(fixedPoint)
        
        
        let spring = SKPhysicsJointSpring.joint(withBodyA: fixedPoint.physicsBody!,
                                                bodyB: flapper.physicsBody!,
                                                anchorA: fixedPoint.position,
                                                anchorB: CGPoint(x: flapper.position.x - flapper.size.width / 2, y: flapper.position.y))
        spring.frequency = 20
        spring.damping = 0.5
        physicsWorld.add(spring)
        
        // this point should
        tipOfFlapper = CGPoint(x: wheelSprite.position.x + size.width/2 - size.width/20, y: 0)
        print(tipOfFlapper)
    }
    
    func createWheel()
    {
        triangleArray = []
        nameArray = []
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
        case 4...6:
            loopFactor = 3
        case 7...10:
            loopFactor = 2
        default:
            loopFactor = 1
        }
        
        let numberOfSectors = studentsNotPickedArray.count * loopFactor
        angle = 2 * Double.pi / Double(numberOfSectors)
        
        let sizeFactor = Double(size.width/2.1) //determines radius of wheel
        let sectorRotationAngle = 2 * Double.pi / Double(numberOfSectors)
        var physicsBodyArray = [SKPhysicsBody]()
        
        //this is an invisible node that the sectors of the wheel get attched to
        wheelSprite = SKShapeNode(circleOfRadius: size.width/2.2)
        wheelSprite.position = CGPoint(x: -size.width/2, y: 0)
        wheelSprite.fillColor = UIColor.clear
        wheelSprite.name = "wheelSprite"
        wheelSprite.zPosition = 1
        addChild(wheelSprite)
        
        // setup coordinates for traingles
        let top = CGPoint(x: sizeFactor * cos(sectorRotationAngle / 2.0), y: sizeFactor * sin(sectorRotationAngle / 2.0))
        let bottom = CGPoint(x: sizeFactor * cos( sectorRotationAngle / -2.0 ), y: sizeFactor * sin(sectorRotationAngle / -2.0 ))
        var points = [CGPoint(x: 0, y: 0), top, bottom]
        
        //add the sectors around the wheel
        for i in 0..<numberOfSectors
        {
            //make a triangle
            let triangleShapeNode = SKShapeNode(points: &points, count: points.count)
            triangleShapeNode.zRotation = CGFloat(sectorRotationAngle * Double(i))
            triangleShapeNode.fillColor = colorArray[i % colorArray.count]
            triangleShapeNode.strokeColor = UIColor.darkGray
            triangleShapeNode.lineWidth = 3.0
            triangleShapeNode.zPosition = 9
            triangleShapeNode.name = "triangleNode"
            wheelSprite.addChild(triangleShapeNode)
            
            // add a name to the triangle
            let nameLabel = SKLabelNode(text: "")
            
            let currentStudent = studentsNotPickedArray[i % studentsNotPickedArray.count]
            nameLabel.text = currentStudent.name
            nameLabel.fontColor = UIColor.white
            nameLabel.fontSize = CGFloat(size.width / 14.0 - CGFloat(loopFactor) * 2.0)
//            nameLabel.fontSize = CGFloat(28.0 - Double(loopFactor) * 2.0)
            nameLabel.fontName = "HelveticaNeue-Bold"
            nameLabel.position = CGPoint(x: size.width/3, y: -10.0)
            nameLabel.name = "NameLabel"
            nameLabel.zPosition = 10
            triangleShapeNode.addChild(nameLabel)
            
            //make a peg
            let pegCenter = CGPoint(x: sizeFactor * cos(sectorRotationAngle / 2.0 + sectorRotationAngle * Double(i)), y: sizeFactor * sin(sectorRotationAngle / 2.0 + sectorRotationAngle * Double(i)))
            let peg = SKShapeNode(circleOfRadius: size.width/75)
            peg.name = "Peg"
            peg.zPosition = 10
            peg.fillColor = UIColor.black
            peg.position = pegCenter
            peg.physicsBody = SKPhysicsBody(circleOfRadius: size.width/75, center: pegCenter)
            peg.physicsBody?.isDynamic = true
            peg.physicsBody?.affectedByGravity = false
            //peg.physicsBody?.friction = 100
            peg.physicsBody?.categoryBitMask = pegCategory
            peg.physicsBody?.collisionBitMask = flapperCategory
            peg.physicsBody?.contactTestBitMask = flapperCategory
            physicsBodyArray.append(peg.physicsBody!)
            wheelSprite.addChild(peg)
            //triangleShapeNode.addChild(peg)
            
            let newWheelTriangle = WheelTriangle(triangle: triangleShapeNode, label: nameLabel, student: currentStudent, peg: peg)
            wheelTriangleArray.append(newWheelTriangle)

        }
        

        wheelSprite.physicsBody = SKPhysicsBody(circleOfRadius: size.width/2 - 25)
        physicsBodyArray.append(wheelSprite.physicsBody!)
        wheelSprite.physicsBody = SKPhysicsBody(bodies: physicsBodyArray)
        wheelSprite.physicsBody?.affectedByGravity = false
        wheelSprite.physicsBody?.allowsRotation = true
        wheelSprite.physicsBody?.pinned = true
        wheelSprite.physicsBody?.angularDamping = 1
        wheelSprite.physicsBody?.isDynamic = true
        
        
    }
    
    func removeWheel()
    {
        spinning = false
        
        wheelTriangleArray.removeAll()
        wheelSprite.removeFromParent()
        
    }
    
    override func update(_ currentTime: TimeInterval) {
//        if spinning {
            guard let node = atPoint(tipOfFlapper) as? SKShapeNode else {return}
            
            print(node.name ?? "NoName")
            for wheelTriangle in wheelTriangleArray {
                if wheelTriangle.triangle == node {
                    let currentStudent = wheelTriangle.student
                    nameLabel.text = currentStudent.name
                    let image = currentStudent.photo
                    let texture = SKTexture(image: image)
                    avatarNode.texture = texture
                    avatarBackgroundNode.color = currentStudent.color
                    avatarBackgroundNode.colorBlendFactor = 1.0
                    print(currentStudent.name)
                    //                    wheelSprite.physicsBody?.angularVelocity
                    print(wheelSprite.physicsBody?.angularVelocity ?? 100)
                    //                    if (wheelSprite.physicsBody?.angularVelocity)!.magnitude < CGFloat(0.1) && spinning == true {
//                    if (wheelSprite.physicsBody?.angularVelocity)! > 0.0 && spinning == true {
//
//                        //the wheel stopped!
//                        spinning = false
//                        print("jumped in with selectedStudent: \(currentStudent.name)")
//                        wheelSprite.physicsBody?.angularVelocity = 0.01
//
//                        nameLabel.text = currentStudent.name + "!"
//                        nameLabel.fontSize = 90.0
//                        speak(textToSpeak: currentStudent.name)
//                    }
                }
            }
//        }
        
    }
    
    // this gets triggered everytime there is a contact
    func didBegin(_ contact: SKPhysicsContact)
    {
//        print("contact with A: \(contact.bodyA.node?.name ?? "ErrorA") and B:\(contact.bodyB.node?.name ?? "ErrorB")")
        run(tickSound)
        
    }
    
    
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
        createWheel()
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
            if !allowsRepeats && studentsNotPickedArray.count > 1
            {
                
            }
            
            var randomSpin = CGFloat(arc4random_uniform(100)+200)
            if UIDevice.current.userInterfaceIdiom == .pad {
                randomSpin += 10000
            }
            wheelSprite.physicsBody?.applyAngularImpulse(-1.0 * CGFloat(randomSpin))
            spinning = true
            nameLabel.fontSize = 50.0
            print("begin spin")
        }
    }
    
}
