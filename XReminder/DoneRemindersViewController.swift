//
//  SecondViewController.swift
//  XReminder
//
//  Created by Xiaoxiao on 6/15/17.
//  Copyright © 2017 WangXiaoxiao. All rights reserved.
//

import UIKit
import UserNotifications

class DoneRemindersViewController: UITableViewController {

    // MARK: Properties
    
    var items = [Item]()
    var doneItems = [Item]()
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        // Set the title color
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor(red: 0.0, green: 128.0 / 255.0, blue: 128.0 / 255.0, alpha: 1)]
        
        if let savedItems = loadItems() {
            items = savedItems
        }
        
        if let savedDoneItems = loadDoneItems() {
            doneItems = savedDoneItems
        }
        
        // Use the edit button provided by the table view controller.
        navigationItem.leftBarButtonItem = editButtonItem
        
        // When switch from reminders scene.
        organizeDoneItems()
        tableView.reloadData()
        
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return doneItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "reminder", for: indexPath) as! ReminderTableViewCell
        
        // Configure the cell
        let item = doneItems[indexPath.row]
        cell.titleLabel.text = item.title
        cell.subtitleLabel.text = item.subtitle
        
        // Convert the absolute time into time of current time zone
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        cell.dateLabel.text = dateFormatter.string(from: item.date)
        
        // Set the checkmark of each cell
        cell.checkMark.tag = indexPath.row
        cell.checkMark.setImage(UIImage(named: "checked"), for: .normal)
        cell.checkMark.addTarget(self, action: #selector(RemindersViewController.checkMark), for: UIControlEvents.touchUpInside)
        
        return cell
    }
    
    func checkMark(sender: UIButton!){
        
        // Change the status of that item
        let row = sender.tag
        let item = doneItems[row]
        
        self.setNotification(item: item)
        
        items.append(item)
        doneItems.remove(at: row)
        
        saveItems()
        saveDoneItems()
        tableView.reloadData()
        
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        return true
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        // Only delete operation is allowed.
        if editingStyle == .delete {
            // Delete the row from the data source
            doneItems.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            saveDoneItems()
        }
        
    }
    
    // Arrange the table list in the order of time.
    func organizeDoneItems() {
        
        if !doneItems.isEmpty {
            
            // Sort all the elements in the order of time
            doneItems.sort {$0.date < $1.date}
            
        }
    }
    
    
    // Set up and add the notification for the reminder
    func setNotification(item: Item) {
        
        let content = UNMutableNotificationContent()
        content.title = item.title
        content.body = item.subtitle
        content.sound = UNNotificationSound.default()
        let unit: Set<Calendar.Component> = [.month, .day, .year, .minute, .hour]
        let dateComponents = Calendar.current.dateComponents(unit, from: item.date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: item.title + item.subtitle + String(describing: item.date), content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { (error) in
            if error != nil {
                print ("error adding notification:\(String(describing: error?.localizedDescription))")
            }
        }
        
    }

    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "ItemDetail" {
            
            let itemViewController = segue.destination as! DetailViewController
            
            //  Get the cell that generates this segue.
            if let selectedCell = sender as? ReminderTableViewCell {
                let indexPath = tableView.indexPath(for: selectedCell)!
                let selectedItem = doneItems[indexPath.row]
                itemViewController.item = selectedItem
                itemViewController.hidesBottomBarWhenPushed = true
            }
            
        }
    }
    
    // MARK: NSCoding
    
    func saveItems() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(items, toFile: Item.ArchiveURL.path)
        if !isSuccessfulSave {
            print("Failed to save items...")
        }
    }
    
    func saveDoneItems() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(doneItems, toFile: Item.doneURL.path)
        if !isSuccessfulSave {
            print("Failed to save done items...")
        }
    }
    
    func loadItems() -> [Item]? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: Item.ArchiveURL.path) as? [Item]
    }
    
    func loadDoneItems() -> [Item]? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: Item.doneURL.path) as? [Item]
    }
    
    
    
}
