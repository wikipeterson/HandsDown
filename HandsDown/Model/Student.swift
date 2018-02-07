//
//  Student.swift
//  HandsDown
//
//  Created by Christopher Walter on 1/10/18.
//  Copyright © 2018 WikipetersonAssistStatApps. All rights reserved.
//

import UIKit
import CloudKit

class Student
{
    var name: String = "default name"
    var photo: UIImage = #imageLiteral(resourceName: "sampleStudentImage")
    var classID: String = ""
    var picked = false
    var record: CKRecord?
    var recordName: String
    
    init(name: String, photo: UIImage)
    {
        self.name = name
        self.photo = photo
        self.classID = ""
        record = nil
        recordName = ""
    }
    
    init(record: CKRecord) {
        self.name = record["name"] as? String ?? ""
        self.classID = record["classID"] as? String ?? ""
        self.record = record
        self.recordName = record.recordID.recordName
        // load photo, it is saved as a CKAsset
        if let asset = record["photo"] as? CKAsset {
            let imageData: Data
            do {
                imageData = try Data(contentsOf: asset.fileURL)
            } catch {
                return
            }
            if let image = UIImage(data: imageData) {
                photo = image
            } else {
                photo = #imageLiteral(resourceName: "Monkey")
            }
        } else {
            photo = #imageLiteral(resourceName: "Monkey")
        }
    }
}
