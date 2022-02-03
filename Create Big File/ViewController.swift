//
//  ViewController.swift
//  Create Big File
//
//  Created by Павел Зыков on 27.01.2022.
//

import UIKit
import CryptoKit

class ViewController: UIViewController {
    
    @IBOutlet var textField: UITextField!
    @IBOutlet var segmentedControl: UISegmentedControl!
    
    @IBAction func button(_ sender: UIButton) {
        if textField.text?.isEmpty == false {
            shared()
        }
    }
    
    @IBAction func changeSegment(_ sender: UISegmentedControl) {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            multiplier = 1024
        case 1:
            multiplier = Int(pow(1024.0, 2.0))
        case 2:
            multiplier = Int(pow(1024.0, 3.0))
        default:
            break
        }
    }
    
    var multiplier = 1024
    
    func shared() {
        
        guard let count = Int(textField.text!) else {
            print("count must be Int")
            return
        }
        
        let fileManager = FileManager.default
        
        guard let url = fileManager.urls(
            for: .documentDirectory,
               in: .userDomainMask
        ).first else {
            return
        }
        
        let newFolderUrl = url.appendingPathComponent("big-file")
        
        print(newFolderUrl.path)
        
        var data: Data?
//        var md5String: String?
        
        do {
            data = try secureRandomData(count: count * multiplier)
            let md5String = Insecure.MD5.hash(data: data!).map { String(format: "%02hhx", $0) }.joined()
            
            let fileUrl = newFolderUrl.appendingPathComponent(md5String + ".tmp")
            
            fileManager.createFile(
                atPath: fileUrl.path,
                contents: data,
                attributes: [FileAttributeKey.creationDate: Date()]
            )
            
            let activityItems = [fileUrl]
            let activityViewController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
            
            self.present(activityViewController, animated: true, completion: nil)
            
            activityViewController.completionWithItemsHandler = { (activityType: UIActivity.ActivityType?,
                                                                   completed: Bool,
                                                                   arrayReturnedItems: [Any]?,
                                                                   error: Error?) in
                completed ? print("share completed") : print("share cancel")
                
//                if fileManager.fileExists(atPath: fileUrl.path) {
//                    do {
//                        try fileManager.removeItem(at: fileUrl)
//                    } catch {
//                        print(error)
//                    }
//                }
                
                if let shareError = error {
                    print("error while sharing: \(shareError.localizedDescription)")
                }
                return
            }
        } catch {
            print(error.localizedDescription)
        }
        
        
    }
    
    func secureRandomData(count: Int) throws -> Data? {
        var bytes = [Int8](repeating: 0, count: count)
        
        let status = SecRandomCopyBytes(kSecRandomDefault, count, &bytes)
        
        if status == errSecSuccess {
            let data = Data(bytes: bytes, count: count)
            return data
        } else {
            return nil
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
    }
    
    
}

