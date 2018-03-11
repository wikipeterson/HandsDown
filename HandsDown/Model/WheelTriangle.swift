//
//  WheelTriangle.swift
//  HandsDown
//
//  Created by Christopher Walter on 3/4/18.
//  Copyright © 2018 WikipetersonAssistStatApps. All rights reserved.
//

import UIKit
import SpriteKit

class WheelTriangle {
    var triangle: SKShapeNode
    var label: SKLabelNode
    var student: Student
    
    init(triangle: SKShapeNode, label: SKLabelNode, student: Student) {
        self.triangle = triangle
        self.label = label
        self.student = student
    }
}
