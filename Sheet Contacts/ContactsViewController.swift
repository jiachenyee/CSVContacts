//
//  ContactsViewController.swift
//  Sheet Contacts
//
//  Created by JiaChen(: on 12/3/20.
//  Copyright © 2020 jiachen. All rights reserved.
//

import UIKit
import ContactsUI
import CSV

class ContactsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var importedContent: String!
    var csv: CSVReader!
    var contactValues = ["Name Prefix",
                         "Given Name",
                         "Middle Name",
                         "Family Name",
                         "Previous Family Name",
                         "Name Suffix",
                         "Nickname",
                         "Phonetic Given Name",
                         "Phonetic Middle Name",
                         "Phonetic Family Name",
                         "Job Title",
                         "Department Name",
                         "Organization Name",
                         "Phonetic Organization Name",
                         "Postal Code",
                         "Email Address",
                         "URL Address",
                         "Phone Number",
                         "Note", "--nil--"]
    var selectedOptions: [String] = []
    
    var postalAddresses: [[String]] = []
    var emailAddresses: [[String]] = []
    var urlAddresses: [[String]] = []
    var phoneNumbers: [[String]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        csv = try! CSVReader(string: importedContent, hasHeaderRow: true)
        
        for _ in 0...csv.headerRow!.count - 1 {
            selectedOptions.append("???")
            postalAddresses.append([])
            emailAddresses.append([])
            urlAddresses.append([])
            phoneNumbers.append([])
            
        }
    }
    
    func saveToContacts() {
        
        if selectedOptions.contains("???") {
            let alert = UIAlertController(title: "Error", message: "Ensure that there are no '???' in the Contact Field column", preferredStyle: UIAlertController.Style.alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            
            self.present(alert, animated: true, completion: nil)

            return
        }
        
        var rowCount = 0
        
        while let row = csv.next() {
            let contact = CNMutableContact()
            
            for i in 0...row.count - 1 {
                switch selectedOptions[i] {
                case "Name Prefix":
                    contact.namePrefix = row[i]
                case "Given Name":
                    contact.givenName = row[i]
                case "Middle Name":
                    contact.middleName = row[i]
                case "Family Name":
                    contact.familyName = row[i]
                case "Previous Family Name":
                    contact.previousFamilyName = row[i]
                case "Name Suffix":
                    contact.nameSuffix = row[i]
                case "Nickname":
                    contact.nickname = row[i]
                case "Phonetic Given Name":
                    contact.phoneticGivenName = row[i]
                case "Phonetic Middle Name":
                    contact.phoneticMiddleName = row[i]
                case "Phonetic Family Name":
                    contact.phoneticFamilyName = row[i]
                case "Job Title":
                    contact.jobTitle = row[i]
                case "Department Name":
                    contact.departmentName = row[i]
                case "Organization Name":
                    contact.organizationName = row[i]
                case "Phonetic Organization Name":
                    contact.phoneticOrganizationName = row[i]
                case "Postal Code":
                    
                    let code = CNMutablePostalAddress()
                    code.postalCode = row[i]
                    
                    let labeledValue = CNLabeledValue(label: postalAddresses[i][0], value: code as CNPostalAddress)
                    contact.postalAddresses.append(labeledValue)
                case "Email Address":
                    
                    let labeledValue = CNLabeledValue(label: emailAddresses[i][0], value: NSString(string: row[i]))
                    contact.emailAddresses.append(labeledValue)
                case "URL Address":
                    
                    let labeledValue = CNLabeledValue(label: urlAddresses[i][0], value: NSString(string: row[i]))
                    contact.urlAddresses.append(labeledValue)
                case "Phone Number":
                    let phoneNumber = CNPhoneNumber(stringValue: row[i])
                    let labeledValue = CNLabeledValue(label: phoneNumbers[i][0], value: phoneNumber)
                    
                    contact.phoneNumbers.append(labeledValue)
                case "Note":
                    contact.note = row[i]
                default:
                    break
                }
            }
            
            let saveRequest = CNSaveRequest()
            
            saveRequest.add(contact, toContainerWithIdentifier: nil)
            
            let store = CNContactStore()
            
            do {
                try store.execute(saveRequest)
            } catch {
                
                print(error.localizedDescription)
            }
            
            rowCount += 1
        }
        
        let alert = UIAlertController(title: "Task Complete", message: "Saved to Contacts", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
            self.dismiss(animated: true)
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    @IBAction func saveToContactsButtonPressed(_ sender: Any) {
        
        saveToContacts()
    }
    
    @IBAction func dismissButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return csv.headerRow?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.textLabel!.text = csv.headerRow![indexPath.row]
        cell.detailTextLabel!.text = selectedOptions[indexPath.row]
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let alert = UIAlertController(title: "Select a Contact Field", message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        
        for i in 0...contactValues.count - 1 {
            alert.addAction(UIAlertAction(title: contactValues[i], style: .default, handler: { (alertAction) in
                if ["Postal Code", "Email Address", "URL Address", "Phone Number"].contains(alertAction.title!) {
                    
                    DispatchQueue.main.async {
                        let textAlert = UIAlertController(title: "Label for \(alertAction.title!)", message: "Type a label value for the item. E.g. iPhone, Work", preferredStyle: UIAlertController.Style.alert)
                        
                        textAlert.addTextField { (field) in
                            field.placeholder = "Label value"
                        }
                        
                        textAlert.addAction(UIAlertAction(title: "Done", style: .default, handler: { (action) in
                            
                            switch alertAction.title! {
                            case "Postal Code":
                                self.postalAddresses[indexPath.row].append(textAlert.textFields![0].text!)
                            case "Email Address":
                                self.emailAddresses[indexPath.row].append(textAlert.textFields![0].text!)
                            case "URL Address":
                                self.urlAddresses[indexPath.row].append(textAlert.textFields![0].text!)
                            case "Phone Number":
                                self.phoneNumbers[indexPath.row].append(textAlert.textFields![0].text!)
                            default:
                                break
                            }
                        }))
                        
                        textAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                        
                        self.present(textAlert, animated: true, completion: nil)
                    }
                }
                self.selectedOptions[indexPath.row] = alertAction.title!
                tableView.reloadData()
            }))
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        let cell = tableView.cellForRow(at: indexPath)
        
        alert.popoverPresentationController?.sourceRect = cell!.frame
        alert.popoverPresentationController?.sourceView = cell
        alert.popoverPresentationController?.permittedArrowDirections = .up
        
        self.present(alert, animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
