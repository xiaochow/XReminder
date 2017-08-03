//
//  Item.swift
//  XReminder
//
//  Created by Xiaoxiao on 6/16/17.
//  Copyright © 2017 WangXiaoxiao. All rights reserved.
//

import Foundation

class Item: NSObject, NSCoding {
    
    // MARK: Properties
    var title: String
    var subtitle: String
    var date: Date
    
    // MARK: Archiving Paths
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("items")
    static let doneDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).last!
    static let doneURL = doneDirectory.appendingPathComponent("doneItems")

    //  MARK: Types
    struct PropertyKey {
        
        static let titleKey = "title"
        static let subtitleKey = "subtitle"
        static let dateKey = "date"
        
    }
    
    // MARK: Initialization
    init?(title: String, subtitle: String, date: Date){
        
        self.title = title
        self.subtitle = subtitle
        self.date = date
        
        super.init()
        
        if title .isEmpty {
            return nil
        }
    }
    
    //  MARK: NSCoding
    func encode(with aCoder: NSCoder) {
        aCoder.encode(title, forKey: PropertyKey.titleKey)
        aCoder.encode(subtitle, forKey: PropertyKey.subtitleKey)
        aCoder.encode(date, forKey: PropertyKey.dateKey)
        
    }
    
    //  NSCoding initiaition.
    required convenience init?(coder aDecoder: NSCoder) {
        
        let title = aDecoder.decodeObject(forKey: PropertyKey.titleKey) as! String
        let subtitle = aDecoder.decodeObject(forKey: PropertyKey.subtitleKey) as! String
        let date = aDecoder.decodeObject(forKey: PropertyKey.dateKey) as! Date
        
        self.init(title: title, subtitle: subtitle, date: date)
    }

}
