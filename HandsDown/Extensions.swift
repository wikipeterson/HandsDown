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
    // this will be used when saving photo to cloudkit.
    func deleteTempImageURL(url: URL) {
        do {
            try FileManager.default.removeItem(at: url)
        } catch let e {
            print("Error deleting temp file: \(e)")
        }
    }
    // this will be used when saving photo to cloudkit.
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
    
    // this is used to make sure that user is signed into icloud.  Must be signed in, in order to save/ load classes
    func isICloudContainerAvailable()->Bool {
        if let currentToken = FileManager.default.ubiquityIdentityToken {
            print(currentToken)
            return true
        } else {
            print("Not signed into iCloud")
            return false
        }
    }
    
    
}

// this extension is used to get the size of image inside of imageview so that we can put a color background on the avatars.
extension UIImageView{
    func frameForImageInImageViewAspectFit() -> CGRect
    {
        if  let img = self.image {
            let imageRatio = img.size.width / img.size.height;
            let viewRatio = self.frame.size.width / self.frame.size.height;
            if(imageRatio < viewRatio) {
                let scale = self.frame.size.height / img.size.height;
                let width = scale * img.size.width;
                let topLeftX = (self.frame.size.width - width) * 0.5;
                return CGRect(x: topLeftX, y: 0, width: width, height: self.frame.size.height)
            }
            else {
                let scale = self.frame.size.width / img.size.width;
                let height = scale * img.size.height;
                let topLeftY = (self.frame.size.height - height) * 0.5;
                return CGRect(x: 0, y: topLeftY, width: self.frame.size.width, height: height)
            }
        }
        return CGRect(x: 0, y: 0, width: 0, height: 0)
    }
}



extension UIColor{
//    static let hDDarkGrayColor = UIColor(red: 67.0/255.0, green: 53.0/255.0, blue: 53.0/255, alpha: 1.0)
//    static let hDLightGrayColor = UIColor(red: 171.0/255.0, green: 174.0/255.0, blue: 186.0/255, alpha: 1.0)
//    static let hDLightBlueColor = UIColor(red: 96.0/255.0, green: 139.0/255.0, blue: 188.0/255, alpha: 1.0)
//    static let hDDarkBlueColor = UIColor(red: 57.0/255.0, green: 83.0/255.0, blue: 169.0/255, alpha: 1.0)
    
    
    
    // see http://bootflat.github.io/documentation.html for colors
    static let blueJeansLight = UIColor(red: 93/255, green: 156/255, blue: 236/255, alpha: 1.0) /* #5d9cec */
    static let blueJeansDark = UIColor(red: 74/255, green: 137/255, blue: 220/255, alpha: 1.0) /* #4a89dc */
    static let aquaDark = UIColor(red: 59/255, green: 175/255, blue: 218/255, alpha: 1.0) /* #3bafda */
    static let aquaLight = UIColor(red: 79/255, green: 193/255, blue: 233/255, alpha: 1.0) /* #4fc1e9 */
    static let mintLight = UIColor(red: 72/255, green: 207/255, blue: 173/255, alpha: 1.0) /* #48cfad */
    static let mintDark = UIColor(red: 55/255, green: 188/255, blue: 155/255, alpha: 1.0) /* #37bc9b */
    static let grassLight = UIColor(red: 160/255, green: 212/255, blue: 104/255, alpha: 1.0) /* #a0d468 */
    static let grassDark = UIColor(red: 140/255, green: 193/255, blue: 82/255, alpha: 1.0) /* #8cc152 */
    static let sunFlowerLight = UIColor(red: 255/255, green: 206/255, blue: 84/255, alpha: 1.0) /* #ffce54 */
    static let sunFlowerDark = UIColor(red: 246/255, green: 187/255, blue: 66/255, alpha: 1.0) /* #f6bb42 */
    static let bitterSweetLight = UIColor(red: 252/255, green: 110/255, blue: 81/255, alpha: 1.0) /* #fc6e51 */
    static let bitterSweetDark = UIColor(red: 233/255, green: 87/255, blue: 63/255, alpha: 1.0) /* #e9573f */
    static let grapefruitLight = UIColor(red: 237/255, green: 85/255, blue: 101/255, alpha: 1.0) /* #ed5565 */
    static let grapefruitDark = UIColor(red: 218/255, green: 68/255, blue: 83/255, alpha: 1.0) /* #da4453 */
    static let lavendarLight = UIColor(red: 172/255, green: 146/255, blue: 236/255, alpha: 1.0) /* #ac92ec */
    static let lavendarDark = UIColor(red: 150/255, green: 122/255, blue: 220/255, alpha: 1.0) /* #967adc */
 
    //    PINK ROSE
    //    0xEC87C0, 0xD770AD
    //
    //    LIGHT GRAY
    //    0xF5F7FA, 0xE6E9ED
    //
    //    MEDIUM GRAY
    //    0xCCD1D9, 0xAAB2BD
    //
    //    DARK GRAY
    //    0x656D78, 0x434A54
    
    
}


