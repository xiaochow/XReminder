//
//  FirstViewController.swift
//  XReminder
//
//  Created by Xiaoxiao on 6/15/17.
//  Copyright © 2017 WangXiaoxiao. All rights reserved.
//

import UIKit
import UserNotifications

class RemindersViewController: UITableViewController, UNUserNotificationCenterDelegate {
    
    
    // MARK: Properties
    var items = [Item]()
    var doneItems = [Item]()
    
    override func viewWillAppear(_ animated: Bool) {
       
        super.viewWillAppear(animated)
        
        // Get the authorization for notifications
        UNUserNotificationCenter.current().delegate = self
        
        // Set the title color
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor(red: 0.0, green: 128.0 / 255.0, blue: 128.0 / 255.0, alpha: 1)]

        // Load the saved items
        if let savedItems = loadItems() {
            items = savedItems
        }
        
        if let savedDoneItems = loadDoneItems() {
            doneItems = savedDoneItems
        }
        
        // Use the edit button provided by the table view controller.
        navigationItem.leftBarButtonItem = editButtonItem
        
        // When switch from done reminders scene.
        organizeItems()
        tableView.reloadData()
        
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "reminder", for: indexPath) as! ReminderTableViewCell
        
        // Configure the cell
        let item = items[indexPath.row]
        cell.titleLabel.text = item.title
        cell.subtitleLabel.text = item.subtitle
        
        // Convert the absolute time into time of current time zone
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        cell.dateLabel.text = dateFormatter.string(from: item.date)
        
        // Set the checkmark of each cell
        cell.checkMark.tag = indexPath.row
        cell.checkMark.setImage(UIImage(named: "check"), for: .normal)
        cell.checkMark.addTarget(self, action: #selector(RemindersViewController.checkMark), for: UIControlEvents.touchUpInside)
        
        return cell
    }

    
    func checkMark(sender: UIButton!){
    
        // Change the checkmark
        sender.setImage(UIImage(named: "checked"), for: .normal)
        
        // Change the status of that item
        let row = sender.tag
        let item = items[row]
        
        // Remove the pending notification of the item
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [item.title + item.subtitle + String(describing: item.date)])
        
        // Change the two arrays
        doneItems.append(item)
        items.remove(at: row)
        saveItems()
        saveDoneItems()
        
        // Reload the table view
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
            
            let item = items[indexPath.row]
            // Delete the row from the data source
            items.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            // Remove the pending notification of the item
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [item.title + item.subtitle + String(describing: item.date)])
        }
        
        saveItems()
    }
    
    
    // To receive information passed from other view controllers.
    @IBAction func unwindToReminderList(_ sender: UIStoryboardSegue) {
        
        if let sourceViewController = sender.source as? ReminderViewController, let item = sourceViewController.item {
            
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                
                let oldItem = items[selectedIndexPath.row]
                // Remove the pending notification of old item.
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [oldItem.title + oldItem.subtitle + String(describing:oldItem.date)])

                //  Update an existing item.
                items[selectedIndexPath.row] = item

            }
            else{
                // Add a new item.
                items.append(item)
            }
            
            // Add the new pending notification.
            setNotification(item: item)
            
            // Update the array and table view.
            organizeItems()
            saveItems()
            tableView.reloadData()
        }
    }

    // Arrange the table list in the order of time.
    func organizeItems() {
        
        if !items.isEmpty {
            
            // Sort all the elements in the order of time
            items.sort {$0.date < $1.date}
    
        }
    }
    
    // Set up and add the notification for the reminder
    func setNotification(item: Item) {
        
        let content = UNMutableNotificationContent()
        content.sound = UNNotificationSound.default()
        content.title = item.title
        content.body = item.subtitle
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
    
    // Prepare for the segue.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "EditItem" {
            
            let itemViewController = segue.destination as! ReminderViewController
            
            //  Get the cell that generates this segue.
            if let selectedCell = sender as? ReminderTableViewCell {
                let indexPath = tableView.indexPath(for: selectedCell)!
                let selectedItem = items[indexPath.row]
                itemViewController.item = selectedItem
                itemViewController.hidesBottomBarWhenPushed = true
            }
            
        }
    }
    
    // MARK: - Delegates
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound, .badge])
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

