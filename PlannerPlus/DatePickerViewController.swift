//
//  DatePickerViewController.swift
//  PlannerPlus
//
//  Created by jackson on 7/7/17.
//  Copyright © 2017 jackson. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class DatePickerViewController: UIViewController
{
    @IBOutlet weak var projectDueDatePicker: UIDatePicker!
    
    let kNone = 0
    let kShow = 1
    let kHide = 2
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(togglePicker), name: Notification.Name(rawValue: "togglePicker"), object: nil)
    }
    
    @objc func togglePicker(notification: Notification)
    {
        if ((notification.object as! NSArray)[0] as! Int) == kShow
        {
            projectDueDatePicker.isHidden = false
            projectDueDatePicker.isUserInteractionEnabled = true
            
            projectDueDatePicker.becomeFirstResponder()
        }
        else
        {
            projectDueDatePicker.isHidden = true
            projectDueDatePicker.isUserInteractionEnabled = false
            
            NotificationCenter.default.post(name: Notification.Name(rawValue: "selectedDueDate"), object: projectDueDatePicker.date)
        }
    }
}
