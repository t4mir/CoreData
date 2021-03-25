//
//  TableViewController.swift
//  ToDoList
//
//  Created by Тамирлан Абаев   on 18.03.2021.
//

import UIKit
import CoreData

class TableViewController: UITableViewController {
    
    var tasks: [Task] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let context = getContext()
//        let fetchRequest:NSFetchRequest<Task>=Task.fetchRequest()
//        if let objects = try? context.fetch(fetchRequest) {
//            for object in objects {
//                context.delete(object)
//            }
//        }
//
//        do {
//            try context.save()
//        } catch let error as NSError {
//            print(error.localizedDescription)
//        }
        
    }

    @IBAction func saveButton(_ sender: UIBarButtonItem) {
        
        let alertController = UIAlertController(title: "New Task", message: "Please add new task", preferredStyle: .alert)
        let savetAction = UIAlertAction(title: "Save", style: .default) { action in
            let textf = alertController.textFields?.first
            if let newTaskTitle = textf?.text {
                self.saveTask(withTitle: newTaskTitle)
                self.tableView.reloadData()
            }
        }
        let cancleAction = UIAlertAction(title: "Cancle", style: .default) { _ in}
        alertController.addTextField { _ in}
        alertController.addAction(savetAction)
        alertController.addAction(cancleAction)
        present(alertController, animated: true, completion: nil)
    }
    
    private func saveTask(withTitle title:String) {
        let context = getContext()
        guard let entity = NSEntityDescription.entity(forEntityName: "Task", in: context) else {return}
        let taskObject = Task(entity: entity, insertInto: context)
        taskObject.title = title
        
        do {
            try context.save()
            tasks.append(taskObject)
        } catch let error as NSError {
            print(error.localizedDescription )
        }
    }
    
    private func getContext()->NSManagedObjectContext {
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        return appdelegate.persistentContainer.viewContext
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let context = getContext()
        let fetchRequest:NSFetchRequest<Task> = Task.fetchRequest()
        
        let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        
        do {
            tasks = try context.fetch(fetchRequest)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return tasks.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let task = tasks[indexPath.row]
        cell.textLabel?.text = task.title
        return cell
    }
}
