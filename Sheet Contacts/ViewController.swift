//
//  ViewController.swift
//  Sheet Contacts
//
//  Created by JiaChen(: on 12/3/20.
//  Copyright © 2020 jiachen. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIDocumentPickerDelegate {

    let vc = UIDocumentPickerViewController(documentTypes: [UTI.commaSeparatedText.rawValue], in: .open)
    var importedContent: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // Set up Files App
        vc.delegate = self
        vc.allowsMultipleSelection = false
        vc.shouldShowFileExtensions = true
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        let url = urls.first!
        
        var documentName = url.lastPathComponent
        documentName.removeLast(url.pathExtension.count + 1)
        
        if url.pathExtension == "csv" {
            do {
                
                importedContent = try String(contentsOf: url)
                
                performSegue(withIdentifier: "contacts", sender: nil)
            } catch {
                print(error.localizedDescription)
                let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: UIAlertController.Style.alert)

                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                
                self.present(alert, animated: true, completion: nil)
            }
        } else {
            let alert = UIAlertController(title: "Error", message: "Please select a CSV file.", preferredStyle: UIAlertController.Style.alert)

            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? ContactsViewController {
            
            dest.importedContent = importedContent
            
        }
    }
    
    @IBAction func selectCsvButtonPressed(_ sender: Any) {
        self.present(vc, animated: true, completion: nil)
    }
}

