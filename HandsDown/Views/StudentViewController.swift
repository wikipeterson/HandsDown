//
//  StudentViewController.swift
//  HandsDown
//
//  Created by Christopher Walter on 2/1/18.
//  Copyright © 2018 WikipetersonAssistStatApps. All rights reserved.
//

import UIKit
import CloudKit

protocol AddStudentDelegate {
    func addStudent(student: Student)

    func updateStudent(student: Student)
}
class StudentViewController: UIViewController, UITextFieldDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // MARK: Outlets
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var imageCollectionView: UICollectionView!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var selectedAvatarLabel: UILabel!
    
    // MARK: Properties
    var delegate: AddStudentDelegate?
    var student: Student?
    var teacher = Teacher()
    let screenSize = UIScreen.main.bounds
    
    var avatars: [UIImage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        avatars = [#imageLiteral(resourceName: "beeImage"),#imageLiteral(resourceName: "sampleStudentImage"), #imageLiteral(resourceName: "foxImage"), #imageLiteral(resourceName: "Monkey"), #imageLiteral(resourceName: "elmoImage"), #imageLiteral(resourceName: "pigTailGirl")]
        setUpViews()
    }
    
    func setUpViews() {
        nameTextField.layer.borderWidth = 3.0
        nameTextField.layer.borderColor = UIColor.lightGray.cgColor
        // if there is a student, populate everything with student details, else make nameTF first Responder and populate imageview with random avatar
        if let myStudent = student {
            nameTextField.text = myStudent.name
            avatarImageView.image = myStudent.photo
        } else {
            let randIndex = Int(arc4random_uniform(UInt32(avatars.count)))
            avatarImageView.image = avatars[randIndex]
            nameTextField.text = ""
            nameTextField.becomeFirstResponder()
        }
    }

    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        
        // save student to cloudKit.
        if student != nil {
            // update student
            guard let name = nameTextField.text, let photo = avatarImageView.image , let myStudent = student else {return}
            // only update if name or photo changed
            if myStudent.name != name || myStudent.photo != photo {
                myStudent.name = name
                myStudent.photo = photo
                updateStudentInCloudKit(theStudent: myStudent)
            }
        } else {
            // save a newStudent
            guard let name = nameTextField.text, let photo = avatarImageView.image else {return}
            saveStudentToCloudKit(name: name, photo: photo)
        }
        dismiss(animated: true, completion: nil)
    }
    
    func updateStudentInCloudKit(theStudent: Student) {

        let newName = nameTextField.text ?? ""
        if let record = theStudent.record {
            record["name"] = newName as NSString
            let photo = avatarImageView.image ?? #imageLiteral(resourceName: "Monkey")
            
            guard let url = convertUIImageToURL(photo: photo) else {return}
            
            record["photo"] = CKAsset(fileURL: url)
            
            let myContainer = CKContainer.default()
            let privateDatabase = myContainer.privateCloudDatabase
            privateDatabase.save(record) {
                (record, error) in
                if let error = error {
                    print(error)
                    return
                }
                // insert successfully saved record code...
                DispatchQueue.main.async(execute: {
                    
                    self.delegate?.updateStudent(student: theStudent)

                })
                // delete temp file for image data
                self.deleteTempImageURL(url: url)
            }
        }
    }
    

    func saveStudentToCloudKit(name: String, photo: UIImage) {
        // create the CKRecord that gets saved to the database
        let uid = UUID().uuidString // get a uniqueID
        let recordID = CKRecordID(recordName: uid)
        let newStudentRecord = CKRecord(recordType: "Student", recordID: recordID)
        newStudentRecord["name"] = name as NSString
        
        // save classID to Student, so that we can fetch the students by classID
        guard let currentClass = teacher.currentClass, let classRecord = currentClass.record else {return}
        
        let classReference = CKReference(record: classRecord, action: .deleteSelf)
        newStudentRecord["classID"] = classReference
        
        // to save picture, I need to save as a CKAsset.  To create CKAsset, first create temp url file, then save photo, and finally delete temp file from memory.  Seems like a lot and try to find a better way
        let data = UIImagePNGRepresentation(photo)// UIImage -> NSData, see also UIImageJPEGRepresentation
        let url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(NSUUID().uuidString+".dat")
        do {
            try data!.write(to: url, options: [])
        } catch let e as NSError {
            print("Error! \(e)")
            return
        }
        newStudentRecord["photo"] = CKAsset(fileURL: url)
        
        let myContainer = CKContainer.default()
        let privateDatabase = myContainer.privateCloudDatabase
        privateDatabase.save(newStudentRecord) {
            (record, error) in
            if let error = error {
                print(error)
                return
            }
            // insert successfully saved record code... reload table, etc...
            let newStudent = Student(record: newStudentRecord)
            
            DispatchQueue.main.async(execute: {
                self.delegate?.addStudent(student: newStudent)
            })
            // delete temp file for image data
            self.deleteTempImageURL(url: url)
        }
    }
    // MARK: CollectionView Methods
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        // change this math to adjust size of cells after you get the size of the avatars from Karen
        let width = (screenSize.width - 4.0) / 3.0

        return CGSize(width: width, height: width + 75)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout
        collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return avatars.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "myCell", for: indexPath) as! AvatarCollectionViewCell
        
        let avatarImage = avatars[indexPath.row]
        cell.avatarImageView.image = avatarImage
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photo = avatars[indexPath.row]
        avatarImageView.image = photo
    }
    
    
    // MARK: TextField methods
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    

}
