//
//  Extensions.swift
//  HandsDown
//
//  Created by Christopher Walter on 2/6/18.
//  Copyright © 2018 WikipetersonAssistStatApps. All rights reserved.
//

import UIKit
import CloudKit


extension UIViewController {
    func deleteTempImageURL(url: URL) {
        do {
            try FileManager.default.removeItem(at: url)
        } catch let e {
            print("Error deleting temp file: \(e)")
        }
    }
    
    func convertUIImageToURL(photo: UIImage) -> URL? {
        let data = UIImagePNGRepresentation(photo)
        let url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(NSUUID().uuidString+".dat")
        do {
            try data!.write(to: url, options: [])
            return url
        } catch let e as NSError {
            print("Error! \(e)")
            return nil
        }
    }
}

extension UIColor{
    static let hDDarkGrayColor = UIColor(red: 67.0/255.0, green: 53.0/255.0, blue: 53.0/255, alpha: 1.0)
    static let hDLightGrayColor = UIColor(red: 171.0/255.0, green: 174.0/255.0, blue: 186.0/255, alpha: 1.0)
    static let hDLightBlueColor = UIColor(red: 96.0/255.0, green: 139.0/255.0, blue: 188.0/255, alpha: 1.0)
    static let hDDarkBlueColor = UIColor(red: 57.0/255.0, green: 83.0/255.0, blue: 169.0/255, alpha: 1.0)
}

