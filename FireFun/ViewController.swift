//
//  ViewController.swift
//  FireFun
//
//  Created by Juan Manuel Jimenez Sanchez on 22/02/17.
//  Copyright © 2017 Juan Manuel Jimenez Sanchez. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class ViewController: UIViewController {

    @IBOutlet weak var myTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var lblUser: UILabel!
    
    var ref: FIRDatabaseReference?
    var handle: FIRDatabaseHandle?
    
    var myList: [[String:String]] = [[String:String]]()
    var userUid = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.ref = FIRDatabase.database().reference()
        
        if let user = FIRAuth.auth()?.currentUser {
            self.userUid = user.uid
            self.lblUser.text = user.email
        }
        
        //Así pintamos cada uno de las notas del usuario en BD
        self.handle = self.ref?.child("notes").queryOrdered(byChild: "userUid").queryEqual(toValue: self.userUid).observe(.childAdded, with: { (snapshot) in
            if var item = snapshot.value as? [String:String] {
                item["uid"] = snapshot.key
                self.myList.insert(item, at: 0)//Así cada nota aparece de primera
                self.myTableView.reloadData()
            }
        })
        
        //Así actualizamos los datos si el usuario edita una nota desde otro dispositivo
        self.handle = self.ref?.child("notes").queryOrdered(byChild: "userUid").queryEqual(toValue: self.userUid).observe(.childChanged, with: { (snapshot) in
            if let item = snapshot.value as? [String:String] {
                //Si se encuentra en el array la nota que se actualizó
                if let index = self.searchNoteBy(key: snapshot.key) {
                    self.myList[index]["title"] = item["title"]
                    self.myList[index]["description"] = item["description"]
                    self.myTableView.reloadData()
                }
            }
        })
    }
    
    ///Retorna el index de la nota indicada por parametro
    func searchNoteBy(key: String) -> Int? {
        for (index, note) in self.myList.enumerated() {
            if note["uid"] == key {
                return index
            }
        }
        
        return nil
    }

    @IBAction func saveBtn(_ sender: UIButton) {
        if let title = self.myTextField.text {
            
            let date = Date()
            let formatter = DateFormatter()
            //formatter.dateFormat = "dd.MM.yyyy"
            formatter.dateStyle = .medium
            formatter.timeStyle = .medium
            
            if let key = self.ref?.child("notes").childByAutoId().key {
                let notes = ["userUid": self.userUid, "title": title, "description": self.descriptionTextField.text!, "date": formatter.string(from: date)] as [String : Any]
                let childUpdates = ["/notes/\(key)": notes]
                self.ref?.updateChildValues(childUpdates)
            }
            
            self.myTextField.text = ""
            self.descriptionTextField.text = ""
        }
    }
    
    @IBAction func logOutAction(_ sender: UIButton) {
        if FIRAuth.auth()?.currentUser != nil {
            do {
                try FIRAuth.auth()?.signOut()
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Login")
                present(vc, animated: true, completion: nil)
                
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.myList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        cell.textLabel?.text = self.myList[indexPath.row]["title"]
        cell.detailTextLabel?.text = self.myList[indexPath.row]["description"]
        
        return cell
    }
}
