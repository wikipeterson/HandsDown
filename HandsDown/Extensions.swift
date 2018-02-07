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

