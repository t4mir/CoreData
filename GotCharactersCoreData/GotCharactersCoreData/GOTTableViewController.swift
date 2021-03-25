//
//  GOTTableViewController.swift
//  GotCharactersCoreData
//
//  Created by Тамирлан Абаев   on 23.03.2021.
//

import UIKit
import CoreData
class GOTTableViewController: UITableViewController {
    
    var characters:[Character] = []

    
    
    @IBAction func addPressed(_ sender: UIBarButtonItem) {
        
        let alertController = UIAlertController(title: "Character", message: "Please write name of character", preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { action in
            let context = self.getContext()
            
            if let entity = NSEntityDescription.entity(forEntityName: "Character", in: context){
            
                let character = NSManagedObject(entity: entity, insertInto: context) as! Character
                
                let name = alertController.textFields![0].text
                let location = alertController.textFields![1].text
                
                character.setValue(name, forKey: "name")
                character.setValue(location, forKey: "location")
                
                do {
                    try context.save()
                    self.characters.append(character)
                    self.tableView.reloadData()
                } catch let error as NSError {
                    print(error.localizedDescription)
                }
                
                
            }
            
            
            
        }
        
        let cancelAction = UIAlertAction(title: "Cancle", style: .default) { _ in}
        
        alertController.addTextField { (textField) in
            textField.placeholder = "Pleas write name"
        }
        alertController.addTextField { (textField) in
            textField.placeholder = "Pleas write location"
        }
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
//        print(characters.count)
    }
    
    
    override func viewDidLoad() {
        characters = loadGot()
        super.viewDidLoad()
        
//        characters = loadGot()
        

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return characters.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        cell.textLabel!.text = characters[indexPath.row].name
        cell.detailTextLabel!.text = characters[indexPath.row].location

        return cell
    }
    

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            deleteGot(characters[indexPath.row])
            characters = loadGot()
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    

    func getContext()->NSManagedObjectContext {
        
        let appDelegete = UIApplication.shared.delegate as! AppDelegate
        return appDelegete.persistentContainer.viewContext
    }
    
    func loadGot()->[Character] {

        let context = self.getContext()
        let fetchReguest = NSFetchRequest<Character>(entityName: "Character")
        do {
            try characters = context.fetch(fetchReguest)
        } catch let error as NSError {
            print(error.localizedDescription)
        }

        return characters
    }
    
    func deleteGot(_ object:Character) {
        
        let context = getContext()
        context.delete(object)
        
        do {
            try context.save()
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
    }

}
