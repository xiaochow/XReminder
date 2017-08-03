//
//  DetailViewController.swift
//  XReminder
//
//  Created by Xiaoxiao on 6/20/17.
//  Copyright © 2017 WangXiaoxiao. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    var item: Item?
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var subtitleView: UITextView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set title color
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor(red: 0.0, green: 128.0 / 255.0, blue: 128.0 / 255.0, alpha: 1)]
        
        // Display the item.
        if let item = item {
            
            titleLabel.text = item.title
            subtitleView.text = item.subtitle
            subtitleView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)

            // Convert the absolute time into time of current time zone
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .short
            dateFormatter.timeStyle = .short
            dateLabel.text = dateFormatter.string(from: item.date)
            
        }
        
    }
    
    @IBAction func back(_ sender: UIBarButtonItem) {
        
        navigationController!.popViewController(animated: true)
        
    }
    

    
}
