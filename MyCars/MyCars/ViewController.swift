//
//  ViewController.swift
//  MyCars
//
//  Created by Ivan Akulov on 08/02/20.
//  Copyright © 2020 Ivan Akulov. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    var car:Car!
    var context :NSManagedObjectContext!
    
    lazy var dateFormatter:DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .short
        df.timeStyle = .none
        return df
    }()
    
    @IBOutlet weak var segmentedControl:  UISegmentedControl! {
        didSet {
            updateSegmentControl()
            segmentedControl.selectedSegmentTintColor = .white
            let whiteTitle = [NSAttributedString.Key.foregroundColor:UIColor.white]
            let blackTitle = [NSAttributedString.Key.foregroundColor:UIColor.black]
            UISegmentedControl.appearance().setTitleTextAttributes(whiteTitle, for: .normal)
            UISegmentedControl.appearance().setTitleTextAttributes(blackTitle, for: .selected)
        }
    }
    @IBOutlet weak var markLabel: UILabel!
    @IBOutlet weak var modelLabel: UILabel!
    @IBOutlet weak var carImageView: UIImageView!
    @IBOutlet weak var lastTimeStartedLabel: UILabel!
    @IBOutlet weak var numberOfTripsLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var myChoiceImageView: UIImageView!
    
    @IBAction func segmentedCtrlPressed(_ sender: UISegmentedControl) {
        
        updateSegmentControl()
        
        
    }
    
    @IBAction func startEnginePressed(_ sender: UIButton) {
        car.timesDriven += 1
        car.lastStarted = Date()
        do {
            try context.save()
            insertDataFrom(selected: car)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    @IBAction func rateItPressed(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Rate", message: "Rate this car please", preferredStyle: .alert)
        let rateAction = UIAlertAction(title: "Rate", style: .default) { action in
            if let text = alertController.textFields?.first?.text {
                self.update(rating:(text as NSString).doubleValue)
            }
        }
            let cancleAction = UIAlertAction(title: "Cancle", style: .default)
            alertController.addTextField { textField in
                textField.keyboardType = .numberPad
            }
            
        alertController.addAction(rateAction)
        alertController.addAction(cancleAction)
        present(alertController, animated: true, completion: nil)
    }
    
    private func update(rating:Double) {
        car.rating = rating
        do {
            try context.save()
            insertDataFrom(selected: car)
        } catch let error as NSError {
            let alertcontroller = UIAlertController(title: "Wrong value", message: "Wrong input", preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "OK", style: .default)
            alertcontroller.addAction(alertAction)
            present(alertcontroller, animated: true, completion: nil)
            print(error.localizedDescription)
        }
    }
    
    
    
    private func getDataFromFile() {
        
        let fetchReguest:NSFetchRequest<Car> = Car.fetchRequest()
        fetchReguest.predicate = NSPredicate(format: "mark != nil")
        
        var records = 0
            
        do {
            records = try context.count(for: fetchReguest)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
        guard records == 0 else {return }
        
        guard let pathToFile = Bundle.main.path(forResource: "data", ofType: "plist"),
              let dictonary = NSArray(contentsOfFile: pathToFile) else {return}
        
        for array in dictonary {
            let entity = NSEntityDescription.entity(forEntityName: "Car", in: context)!
            let car = NSManagedObject(entity: entity, insertInto: context) as! Car
            
            let carDictonary = array as! [String:AnyObject]
            car.mark = carDictonary["mark"] as? String
            car.model = carDictonary["model"] as? String
            car.lastStarted = carDictonary["lastStarted"] as? Date
            car.rating = carDictonary["rating"] as! Double
            car.myChoice = carDictonary["myChoice"] as! Bool
            car.timesDriven = carDictonary["timesDriven"] as! Int16
            
            let image = (carDictonary["imageName"] as? String)!
            let imageName = UIImage.init(named: image)
            let carImage = imageName?.pngData()
            car.imageData = carImage
            
            if let colorDictonary = carDictonary["tintColor"] as? [String:Float] {
                car.tintColor = getColor(colorDictonary:colorDictonary)
            }
        }
    }
    
    private func getColor(colorDictonary:[String:Float]) ->  UIColor {
        guard let red = colorDictonary["red"],
              let green = colorDictonary["green"],
              let blue = colorDictonary["blue"]
              else { return UIColor()}
        return UIColor(red: CGFloat(red/255), green: CGFloat(green/255), blue: CGFloat(blue/255), alpha: 1.0)
    }
    
    private func insertDataFrom(selected car:Car) {
        
        markLabel.text = car.mark
        modelLabel.text = car.model
        myChoiceImageView.isHidden = !(car.myChoice)
        carImageView.image = UIImage.init(data: car.imageData!)
        ratingLabel.text = "Rating: \(car.rating)/10"
        numberOfTripsLabel.text = " Number of trips: \(car.timesDriven)"
        
        lastTimeStartedLabel.text = "Last time started: \(dateFormatter.string(from: car.lastStarted!))"
        segmentedControl.backgroundColor = car.tintColor as? UIColor
    }
    
    
    private func updateSegmentControl() {
        let fetchReguest:NSFetchRequest<Car>=Car.fetchRequest()
        let mark = segmentedControl.titleForSegment(at: segmentedControl.selectedSegmentIndex)
        fetchReguest.predicate = NSPredicate.init(format: "mark==%@",mark!)
        
        do {
            let results = try context.fetch(fetchReguest)
            car = results.first!
            insertDataFrom(selected: car)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    
    override func viewDidLoad() {
        getDataFromFile()
        
        
        
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    
}

