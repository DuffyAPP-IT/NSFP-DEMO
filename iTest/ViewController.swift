//
//  ViewController.swift
//  iTest
//
//  Created by James Duffy on 04/03/2021.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var log_text_view: UITextView!
    
    @IBOutlet weak var operation_type_seg: UISegmentedControl!
    @IBOutlet weak var file_name_text_entry: UITextField!
    @IBOutlet weak var user_data_text_entry: UITextField!
    @IBOutlet weak var protection_type_seg: UISegmentedControl!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        log_text_view.text = ("\(NSDate()) - Launch")
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func list_files_on_disk(_ sender: Any) {
        do {
            write_to_log(msg: "[+] Printing Files In Application Container Documents")
            let directoryContents = try FileManager.default.contentsOfDirectory(at: getDocumentsDirectory(), includingPropertiesForKeys: [.nameKey, .fileProtectionKey])
            for fileURL in directoryContents {
                 do {
                    let fileAttributes = try fileURL.resourceValues(forKeys:[.nameKey, .fileProtectionKey])
                    write_to_log(msg: "file_name:\(fileAttributes.name!)-fp_type:\(fileAttributes.fileProtection?.rawValue ?? "[!] ERROR")")
                 } catch { print(error, fileURL) }
            }
        } catch {
            print(error)
        }
    }
    
    
    @IBAction func delete_file_from_disk(_ sender: Any) {
        let destURL = getDocumentsDirectory().appendingPathComponent("\(file_name_text_entry.text ?? "output.txt")").path
        
        do {
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: destURL) {
                try fileManager.removeItem(atPath: destURL)
                write_to_log(msg: "[+] File Deleted!")
            } else { write_to_log(msg: "[!] File Does Not Exist...") }
        } catch {
            print("[!] An Error Occured While Attempting To Delete File")
        }
    }
    
    
    @IBAction func read_file_from_disk_button_tapped(_ sender: Any) {
        print("READ HIT")
        let user_data = "optional".data(using: .utf8)!
        let destURL = getDocumentsDirectory().appendingPathComponent("\(file_name_text_entry.text ?? "output.txt")")
        file_handler(data: user_data, url: destURL, mode: "read", protectionType: .noFileProtection)
    }
    

    @IBAction func write_file_to_disk_button_tapped(_ sender: Any) {
        print("WRITE HIT")
        print("[@] protection type is -> \(protection_type_seg.selectedSegmentIndex)")
        
        let user_data = user_data_text_entry.text?.data(using: .utf8)
        
        let destURL = getDocumentsDirectory().appendingPathComponent("\(file_name_text_entry.text ?? "output.txt")")
        
        let selected_fpt = protection_type_seg.selectedSegmentIndex
        
        if(selected_fpt==0){
            file_handler(data: user_data!, url: destURL, mode: "write", protectionType: .completeFileProtection)
        } else if (selected_fpt==1) {
            file_handler(data: user_data!, url: destURL, mode: "write", protectionType: .completeFileProtectionUnlessOpen)
        } else if (selected_fpt==2) {
            file_handler(data: user_data!, url: destURL, mode: "write", protectionType: .completeFileProtectionUntilFirstUserAuthentication)
        }  else if (selected_fpt==3) {
            file_handler(data: user_data!, url: destURL, mode: "write", protectionType: .noFileProtection)
        }
    }
    
    func write_to_log(msg: String){
        log_text_view.text = log_text_view.text + "\n" + msg
    }
    
    func file_handler(data: Data, url: URL, mode: String, protectionType: NSData.WritingOptions) {
        if(mode=="write"){
            do {
                try data.write(to: url, options: protectionType)
                write_to_log(msg: "[+] Write (FP:\(protection_type_seg.selectedSegmentIndex)) to Disk (\(url)) Complete!")
            } catch { write_to_log(msg: "[!] Write To Disk (\(url)) Failed...") }
        }
        else if(mode=="read"){
            do{
                let f_data = try String(contentsOf: url, encoding: .utf8)
                write_to_log(msg: "[+] Read Success! \(url) Contains -> \(f_data)")
            } catch { write_to_log(msg: "[!] Reading From Disk Failed...") }
        }
        
    }
    
    
    @IBAction func close_keyboard(_ sender: Any) {
        view.endEditing(true)
    }
    
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
//    func getXDirectory() -> URL {
//        let paths = FileManager.default.urls(for: .cachesDirectory, in: .systemDomainMask)
//        return paths[0]
//    }
}

