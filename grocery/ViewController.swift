//
//  ViewController.swift
//  grocery
//
//  Created by erhan demirci on 7.03.2024.
//

import UIKit
import CloudKit

//https://www.youtube.com/watch?v=Og-2A5n5IAY  CloudKit Grocery List App

class ViewController: UIViewController, UITableViewDataSource {
  
    

    var tableview : UITableView = {
        let tableview = UITableView()
        tableview.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tableview
        
    }()
    var items = [String]()
    
    //private let database = CKContainer.default().privateCloudDatabase
    private let database = CKContainer(identifier: "iCloud.erhanContainer").privateCloudDatabase
    @objc func saveItem(name:String){
        
        
         guard let image = UIImage(named: "sampleImage") else {
            return
        }
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
                    return
        }
        
        let fileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString+".dat")
              do {
                  try imageData.write(to: fileURL)
              } catch {
                  print("Error writing data to temporary file: \(error)")
                  return
        }
              
        let asset = CKAsset(fileURL: fileURL)

      
               
        
        let record = CKRecord(recordType: "GroceryItem")
        
        record.setValue(asset, forKey: "profilePicture")
        
        record.setValue(name, forKey: "name1")
        database.save(record) { record, error in
            if record != nil , error == nil {
                
                print("saved")
            }
        }
    }
    @objc func deleteItem(name:String){
        
        let recordIDToDelete = CKRecord.ID(recordName: name)
        database.delete(withRecordID: recordIDToDelete) { record, error in
            if record != nil , error == nil {
                
                print("deleted")
            }
        }

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Grocery List"
        // Do any additional setup after loading the view.
        view.addSubview(tableview)
        tableview.dataSource = self
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAdd))
        fechItems()
        deleteItem(name: "345AF442-F636-48E7-ACDD-551B008AD9DD")
    }
    @objc func fechItems() {
        let query = CKQuery(recordType: "GroceryItem", predicate: NSPredicate(value: true))
        database.perform(query, inZoneWith: nil) {[weak self] records, error in
            guard let records = records, error == nil else {
                return
            }
            print(records)
            self?.items = records.compactMap({ $0.value(forKey: "name1") as? String
                
            })
            DispatchQueue.main.async {
                self?.tableview.reloadData()
            }
        
        }
    }
    @objc func didTapAdd() {
        let alert = UIAlertController(title: "Add Item", message: "", preferredStyle: .alert)
        
        alert.addTextField { field in
            field.placeholder = " Enter name "
            
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { _ in
            
            if let field = alert.textFields?.first, let text = field.text , !text.isEmpty {
                self.saveItem(name: text)
                
            }
        }))
        present(alert, animated: true)
        
    }
    override func viewDidLayoutSubviews() {
        
        tableview.frame = view.bounds
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = items[indexPath.row]
        return cell
    }


}

