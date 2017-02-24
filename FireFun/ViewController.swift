//
//  ViewController.swift
//  FireFun
//
//  Created by Juan Manuel Jimenez Sanchez on 22/02/17.
//  Copyright © 2017 Juan Manuel Jimenez Sanchez. All rights reserved.
//

import UIKit
import FirebaseDatabase

class ViewController: UIViewController {

    @IBOutlet weak var myTextField: UITextField!
    @IBOutlet weak var myTableView: UITableView!
    
    var ref: FIRDatabaseReference?
    var handle: FIRDatabaseHandle?
    
    var myList: [String] = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.ref = FIRDatabase.database().reference()
        
        //Aquí llenamos el arreglo con los elementos en BD
        self.handle = self.ref?.child("list").observe(.childAdded, with: { (snapshot) in
            if let item = snapshot.value as? String {
                self.myList.append(item)
                self.myTableView.reloadData()
            }
        })
    }

    @IBAction func saveBtn(_ sender: UIButton) {
        if self.myTextField.text != "" {
            self.ref?.child("list").childByAutoId().setValue(self.myTextField.text)
            self.myTextField.text = ""
        }
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.myList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        cell.textLabel?.text = self.myList[indexPath.row]
        
        return cell
    }
}
