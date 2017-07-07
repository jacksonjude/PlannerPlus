//
//  ProjectPickerViewController.swift
//  PlannerPlus
//
//  Created by jackson on 7/6/17.
//  Copyright © 2017 jackson. All rights reserved.
//

import Foundation
import UIKit

class ProjectPickerViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource
{
    @IBOutlet weak var projectSelectionPicker: UIPickerView!
    
    var projectTypeArray = Array<String>()
    var projectSubjectArray = Array<String>()
    
    var pickerIsShown = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let projectTypeArray = UserDefaults.standard.object(forKey: "projectTypes") as? Array<String>
        {
            self.projectTypeArray = projectTypeArray
        }
        
        if let projectSubjectArray = UserDefaults.standard.object(forKey: "projectSubjects") as? Array<String>
        {
            self.projectSubjectArray = projectSubjectArray
        }
        
        projectSelectionPicker.reloadAllComponents()
        
        NotificationCenter.default.addObserver(self, selector: #selector(toggleEditing), name: Notification.Name(rawValue: "toggleEditing"), object: nil)
    }
    
    @objc func toggleEditing()
    {
        projectSelectionPicker.isHidden = !projectSelectionPicker.isHidden
        
        if !projectSelectionPicker.isHidden
        {
            projectSelectionPicker.becomeFirstResponder()
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component
        {
        case 0:
            return projectTypeArray.count
        case 1:
            return projectSubjectArray.count
        default:
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch component
        {
        case 0:
            return projectTypeArray[row]
        case 1:
            return projectSubjectArray[row]
        default:
            return ""
        }
    }
}
