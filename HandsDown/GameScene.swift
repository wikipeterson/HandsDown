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
    
//    var nameArray : [String] = [
//        "Theo", "Scooby", "Marsha"
//        , "Tyrese", "Matthew","Fat Albert"
//        , "Danesh", "Geoff", "Jill", "Sneaky Pete"
//        , "Amy", "Zoey", "Bryn", "Cameron", "Lashawndra"
//        ,"Beth", "Bella","Chunks", "Big Al", "Stinky Pat"
//        , "Milly", "Tuxedo Jack", "Heather", "Shaggy", "John Snow", "McFly", "Billy Two-times", "Dirty Harry", "Flo", "Hung", "Enrique", "Siobhan"
//                    ]
    
    let student1 = Student(name: "Bryn", picture: #imageLiteral(resourceName: "foxImage"))
    let student2 = Student(name: "Lucky", picture: #imageLiteral(resourceName: "beeImage"))
    let student3 = Student(name: "Cameron", picture: #imageLiteral(resourceName: "pigTailGirl"))
    let student4 = Student(name: "Steve", picture: #imageLiteral(resourceName: "Screen Shot 2018-01-03 at 8.59.44 AM"))
    let student5 = Student(name: "Zoey", picture: #imageLiteral(resourceName: "elmoImage"))
    let student6 = Student(name: "Amy", picture: #imageLiteral(resourceName: "sampleStudentImage"))
    var teacher = Teacher()
    var referenceVC : ViewController!
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
    var spinning = false
    var player = AVAudioPlayer()
    let tockSystemSoundID: SystemSoundID = 1105
    let fanfareSystemSoundID: SystemSoundID = 1103
    var holder = Student(name: "", picture: #imageLiteral(resourceName: "sampleStudentImage")) //this is for controlling the click sounds
    var loopFactor = 1 //this is for duplicating small classes on the wheel
    
    override func didMove(to view: SKView)
    {
        nameLabel = childNode(withName: "nameLabel") as! SKLabelNode
        tipOfArrow = childNode(withName: "tipOfArrow") as! SKSpriteNode
        tipOfArrowPoint = CGPoint(x: tipOfArrow.position.x, y: tipOfArrow.position.y)
        nameLabel.fontSize = 40.0
        nameLabel.text = "???"
        
        //get the teacher data from ViewController
        if let currentClass = teacher.currentClass {
            studentArray = currentClass.students
        } else {
            studentArray = [student1, student2, student3]
        }
//        if let currentClass = referenceVC.teacher.currentClass
//        {
//            studentArray = (teacher.currentClass?.students)!
//        } else {
//            studentArray = [student1, student2, student3]
//        }
        //teacher = referenceVC.teacher
        
        
        //set up the node that gets the wheel sectors overlayed
        wheelSprite = childNode(withName: "wheelSprite") as! SKSpriteNode
        wheelSprite.position = CGPoint(x: 0, y: 0)
        wheelSprite.anchorPoint = CGPoint(x: 0.5, y: 0.5  )
        wheelSprite.physicsBody?.angularDamping = 1.0
        
        numberOfSectors = studentArray.count
        placeSectorsOverWheel()
        
    }
    
    func placeSectorsOverWheel()
    {
        switch numberOfSectors
        {
            case 0:
                studentArray.append(Student(name: "empty class", picture: #imageLiteral(resourceName: "foxImage")))
                loopFactor = 12
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

        numberOfSectors = studentArray.count * loopFactor
        angle = 2 * Double.pi / Double(numberOfSectors)
        print("loopFactor = ", loopFactor)
        let theta = 2.0 * Double.pi / Double(numberOfSectors) / 2.0
        for num in 0..<Int(numberOfSectors)
        {
            
            let rect = SKSpriteNode(color: UIColor.white, size: CGSize(width: 250, height: 2 * 250 * tan(theta)))
            rect.position = CGPoint(x: 0, y: 0)
            rect.zPosition = 1
            rect.anchorPoint = CGPoint(x: 0, y: 0.5)
            rect.zRotation = CGFloat(angle * Double(num))
            rectArray.append(rect)
            
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
            
            triangleArray.append(triangleShapeNode)
            wheelSprite.addChild(triangleShapeNode)
            
            let rectLabel = SKLabelNode(text: studentArray[num % studentArray.count].name)
            rectLabel.position = CGPoint(x: 220, y: -10)
            rectLabel.fontColor = UIColor.black
            rectLabel.fontName = "HelveticaNeue"
            rectLabel.fontSize = 20.0
            rectLabel.zPosition = 4
            rectLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.right
            rect.addChild(rectLabel)
            
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
                if rectArray[i].intersects(tipOfArrow)
                {
                    nameLabel.text = studentArray[i % studentArray.count].name
                   
                    if studentArray[i % studentArray.count].name != holder.name
                    {
                        AudioServicesPlaySystemSound(tockSystemSoundID)
                    }
                    holder = studentArray[i % studentArray.count]
                    
                    if (wheelSprite.physicsBody?.angularVelocity)! < CGFloat(0.05)
                    {
                        wheelSprite.physicsBody?.angularVelocity = 0
                       //print("stopped")
                        spinning = false
                        AudioServicesPlaySystemSound(fanfareSystemSoundID)
                        AudioServicesPlaySystemSound(4095)
                        nameLabel.text = studentArray[i % studentArray.count].name + "!"
                        nameLabel.fontSize = 70.0
                    //print(rectArray[i].zRotation)
//                        wheelSprite.zRotation = rectArray[i].zRotation
                        
//                        let correction = SKAction.rotate(byAngle: rectArray[i].zRotation, duration: 2.0)
//                        if spinning
//                        {
//                            wheelSprite.run(correction)
//
//                        }
                    }
                }
            }
            
            
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        let touchLocation = touches.first?.location(in: self)
        
        if wheelSprite.frame.contains(touchLocation!)
        {
            wheelSprite.physicsBody?.applyAngularImpulse(CGFloat(arc4random_uniform(1200)+500))
            //AudioServicesPlaySystemSound(1336)
            spinning = true
            nameLabel.fontSize = 40.0
            nameLabel.text = "???"
        }
    }
    
    
}
