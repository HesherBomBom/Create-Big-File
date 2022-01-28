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
        if (textField.text != nil) {
            shared()
        }
    }
    
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
        do {
            data = try secureRandomData(count: count * Int(pow(1024.0, 2.0)))
        } catch {
            print(error)
        }
        
        var md5String: String?
        if data != nil {
            md5String = Insecure.MD5.hash(data: data!).map { String(format: "%02hhx", $0) }.joined()
        }
        
        let fileUrl = newFolderUrl.appendingPathComponent(md5String! + ".txt")
        
        fileManager.createFile(
            atPath: fileUrl.path,
            contents: data,
            attributes: [FileAttributeKey.creationDate: Date()]
        )
        
        let activityItems = [fileUrl]
        let activityViewController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        
        activityViewController.excludedActivityTypes = [
            UIActivity.ActivityType.airDrop,
            UIActivity.ActivityType.copyToPasteboard
        ]
        
        self.present(activityViewController, animated: true, completion: nil)
        
        activityViewController.completionWithItemsHandler = { (activityType: UIActivity.ActivityType?, completed:
        Bool, arrayReturnedItems: [Any]?, error: Error?) in
            if completed {
                print("share completed")
                if fileManager.fileExists(atPath: fileUrl.path) {
                    do {
                        try fileManager.removeItem(at: fileUrl)
                    } catch {
                        print(error)
                    }
                }
                return
            } else {
                print("cancel")
                if fileManager.fileExists(atPath: fileUrl.path) {
                    do {
                        try fileManager.removeItem(at: fileUrl)
                    } catch {
                        print(error)
                    }
                }
            }
            if let shareError = error {
                print("error while sharing: \(shareError.localizedDescription)")
            }
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

