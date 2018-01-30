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

class GameScene: SKScene
{
    
    let student1 = Student(name: "Bryn", picture: #imageLiteral(resourceName: "foxImage"))
    let student2 = Student(name: "Lucky", picture: #imageLiteral(resourceName: "beeImage"))
    let student3 = Student(name: "Cameron", picture: #imageLiteral(resourceName: "pigTailGirl"))
    let student4 = Student(name: "Steve", picture: #imageLiteral(resourceName: "Screen Shot 2018-01-03 at 8.59.44 AM"))
    let student5 = Student(name: "Zoey", picture: #imageLiteral(resourceName: "elmoImage"))
    let student6 = Student(name: "Amy", picture: #imageLiteral(resourceName: "sampleStudentImage"))
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
    var holder = Student(name: "", picture: #imageLiteral(resourceName: "sampleStudentImage")) //this is for controlling the click sounds
    var loopFactor = 1 //this is for duplicating small classes on the wheel
    var synth = AVSpeechSynthesizer()
    var allowsRepeats = false
    var studentsNotPickedArray : [Student] = []
    var switchLabel = SKLabelNode()
    var avatarNode = SKSpriteNode()
    
    override func didMove(to view: SKView)
    {
        screenWidth = (self.view?.frame.width)!
        screenHeight = (self.view?.frame.height)!
        
        print("did move")
        
        // label not showing up
        
        switchLabel = childNode(withName: "switchLabel") as! SKLabelNode
        switchLabel.text = "Remove repeats"
        //switchLabel.position = CGPoint(x: screenWidth * -0.35, y: screenHeight * -0.41)
        switchLabel.fontColor = SKColor.white
        switchLabel.fontSize = 25.0
        switchLabel.zPosition = 50
        switchLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        
        
        nameLabel = childNode(withName: "nameLabel") as! SKLabelNode
        tipOfArrow = childNode(withName: "tipOfArrow") as! SKSpriteNode
        //tipOfArrowPoint = CGPoint(x: tipOfArrow.position.x, y: tipOfArrow.position.y)
        nameLabel.fontSize = 40.0
        nameLabel.text = "???"
        
        //get the teacher data from ViewController
        if let currentClass = teacher.currentClass {
            studentArray = currentClass.students
            
        } else {
            studentArray = [student1, student2, student3]
        }

        studentsNotPickedArray = studentArray
        
        
        //set up the node that gets the wheel sectors overlayed
        wheelSprite = childNode(withName: "wheelSprite") as! SKSpriteNode
        wheelSprite.position = CGPoint(x: screenWidth * -0.8, y: 0)
        wheelSprite.anchorPoint = CGPoint(x: 0.5, y: 0.5  )
        wheelSprite.physicsBody?.angularDamping = 1.0
        
        avatarNode = childNode(withName: "avatarNode") as! SKSpriteNode
        let image = #imageLiteral(resourceName: "questionMarkImage")
        let texture = SKTexture(image: image)
        avatarNode.texture = texture
        
        placeSectorsOverWheel()
        addRepeatsSwitch()
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
        repeatSwitch.isOn = true
        repeatSwitch.setOn(false, animated: true)
        repeatSwitch.addTarget(self, action: #selector(switchValueDidChange), for: .valueChanged)
        self.view!.addSubview(repeatSwitch)
    }
    
    
    func placeSectorsOverWheel()
    {
        
        rectArray = []
        triangleArray = []
        rectLabelArray = []
        
        switch studentsNotPickedArray.count
        {
            case 0:
                studentArray.append(Student(name: "empty class", picture: #imageLiteral(resourceName: "foxImage")))
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
            let rect = SKSpriteNode(color: UIColor.white, size: CGSize(width: 250, height: 2 * 250 * tan(theta)))
            rect.position = CGPoint(x: 0, y: 0)
            rect.zPosition = 1
            rect.anchorPoint = CGPoint(x: 0, y: 0.5)
            rect.zRotation = CGFloat(angle * Double(num))
            rectArray.append(rect)
            rect.name = "rectNode"
            wheelSprite.addChild(rect)
            
            let topEdge = CGPoint(x: 250.0 * cos(angle / 2.0 + angle * Double(num)), y: 250.0 * sin(angle / 2.0 + angle * Double(num)))
            let bottomEdge = CGPoint(x: 250.0 * cos(angle * Double(num) - angle / 2.0 ), y: 250.0 * sin(angle * Double(num) - angle / 2.0 ))
            var points = [CGPoint(x: 0, y: 0), topEdge, bottomEdge]
            let hue = CGFloat(Double(num) / Double(numberOfSectors))
            let triangleShapeNode = SKShapeNode(points: &points, count: points.count)
            triangleShapeNode.zPosition = 3
            triangleShapeNode.fillColor = UIColor(hue: hue, saturation: 1.0, brightness: 1.0, alpha: 1.0)
            triangleShapeNode.strokeColor = UIColor.black
            triangleShapeNode.lineWidth = 3.0
            triangleShapeNode.name = "triangleNode"
            
            triangleArray.append(triangleShapeNode)
            wheelSprite.addChild(triangleShapeNode)
            
            var rectLabel = SKLabelNode(text: "")
            rectLabel.text = studentsNotPickedArray[num % studentsNotPickedArray.count].name
            rectLabel.position = CGPoint(x: 220, y: -10)
            rectLabel.fontColor = UIColor.black
            rectLabel.fontName = "HelveticaNeue"
            rectLabel.fontSize = 20.0
            rectLabel.zPosition = 4
            rectLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.right
            rect.addChild(rectLabel)
            rect.name = "labelNode"
            rectLabelArray.append(rectLabel)
        }
    }
    
    func removeSectorsFromWheel()
    {
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
    }
    
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
    
    
    override func update(_ currentTime: TimeInterval)
    {
        if spinning
        {
            for i in 0..<(rectArray.count)
            {
                if triangleArray[i].intersects(tipOfArrow)
                {
                    nameLabel.text = studentsNotPickedArray[i % studentsNotPickedArray.count].name
                    let image = studentsNotPickedArray[i % studentsNotPickedArray.count].picture
                    let texture = SKTexture(image: image)
                    avatarNode.texture = texture
                    
                    if studentsNotPickedArray[i % studentsNotPickedArray.count].name != holder.name
                    {
                        AudioServicesPlaySystemSound(tockSystemSoundID)
                    }
                    holder = studentsNotPickedArray[i % studentsNotPickedArray.count]
                    
                    if (wheelSprite.physicsBody?.angularVelocity)! < CGFloat(0.1)
                    {
                        wheelSprite.physicsBody?.angularVelocity = 0
                        
                        AudioServicesPlaySystemSound(fanfareSystemSoundID)
                        AudioServicesPlaySystemSound(4095)
                        nameLabel.text = studentsNotPickedArray[i % studentsNotPickedArray.count].name + "!"
                        nameLabel.fontSize = 70.0
                        speak(textToSpeak: nameLabel.text!)
                        if !allowsRepeats && studentsNotPickedArray.count > 1
                        {
                        studentsNotPickedArray.remove(at: i % studentsNotPickedArray.count)
                        }
                        print(studentsNotPickedArray.count)
                        print("stopped")
                        spinning = false
                        //return
                    }
                }
            }
        }
    }
    
    func speak(textToSpeak: String)
    {
        let utterance = AVSpeechUtterance(string: textToSpeak)
        utterance.voice = AVSpeechSynthesisVoice(language: "us-au") //choose voice
        synth.speak(utterance)
    }
    
    func resetPicks()
    {
        studentsNotPickedArray = studentArray
        placeSectorsOverWheel()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        let touchLocation = touches.first?.location(in: self)
        
        if wheelSprite.frame.contains(touchLocation!)
        {
            wheelSprite.zRotation = 0
            removeSectorsFromWheel()
            placeSectorsOverWheel()
            let randomSpin = CGFloat(arc4random_uniform(1200)+500)
            wheelSprite.physicsBody?.applyAngularImpulse(CGFloat(randomSpin))
            spinning = true
            nameLabel.fontSize = 40.0
            print("begin spin")
        }
    }
    
}
