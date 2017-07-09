//
//  ProjectPickerViewController.swift
//  PlannerPlus
//
//  Created by jackson on 7/6/17.
//  Copyright © 2017 jackson. All rights reserved.
//

import Foundation
import UIKit

class LabelPickerViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource
{
    @IBOutlet weak var projectLabelPicker: UIPickerView!
    
    var projectTypeArray = Array<String>()
    var projectSubjectArray = Array<String>()
    
    var pickerIsShown = false
    
    let kNone = 0
    let kLabels = 1
    let kDueDate = 2
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let projectTypeArray = UserDefaults.standard.object(forKey: "projectTypes") as? Array<String>
        {
            self.projectTypeArray = projectTypeArray
            self.projectTypeArray.append("N/A")
        }
        else
        {
            self.projectTypeArray.append("N/A")
        }
        
        if let projectSubjectArray = UserDefaults.standard.object(forKey: "projectSubjects") as? Array<String>
        {
            self.projectSubjectArray = projectSubjectArray
            self.projectSubjectArray.append("N/A")
        }
        else
        {
            self.projectSubjectArray.append("N/A")
        }
        
        projectLabelPicker.reloadAllComponents()
        
        NotificationCenter.default.addObserver(self, selector: #selector(togglePicker), name: Notification.Name(rawValue: "togglePicker"), object: nil)
    }
    
    @objc func togglePicker(notification: Notification)
    {
        if ((notification.object as! NSArray)[0] as! Int) == kLabels
        {
            projectLabelPicker.isHidden = false
            projectLabelPicker.isUserInteractionEnabled = true
            
            projectLabelPicker.becomeFirstResponder()
            
            if (notification.object as! NSArray)[1] is String
            {
                if let projectTypeIndex = projectTypeArray.index(of: (notification.object as! NSArray)[1] as! String)
                {
                    projectLabelPicker.selectRow(projectTypeIndex, inComponent: 0, animated: true)
                }
            }
            
            if (notification.object as! NSArray)[2] is String
            {
                if let projectSubjectIndex = projectSubjectArray.index(of: (notification.object as! NSArray)[2] as! String)
                {
                    projectLabelPicker.selectRow(projectSubjectIndex, inComponent: 1, animated: true)
                }
            }
        }
        else
        {
            projectLabelPicker.isHidden = true
            projectLabelPicker.isUserInteractionEnabled = false
            
            let projectType = projectTypeArray[projectLabelPicker.selectedRow(inComponent: 0)]
            NotificationCenter.default.post(name: Notification.Name(rawValue: "selectedProjectType"), object: projectType)
            
            let projectSubject = projectSubjectArray[projectLabelPicker.selectedRow(inComponent: 1)]
            NotificationCenter.default.post(name: Notification.Name(rawValue: "selectedProjectSubject"), object: projectSubject)
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
