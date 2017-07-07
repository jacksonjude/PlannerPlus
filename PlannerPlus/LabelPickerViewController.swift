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
        
        NotificationCenter.default.addObserver(self, selector: #selector(toggleEditing), name: Notification.Name(rawValue: "toggleEditing"), object: nil)
    }
    
    @objc func toggleEditing()
    {
        projectLabelPicker.isHidden = !projectLabelPicker.isHidden
        
        if !projectLabelPicker.isHidden
        {
            projectLabelPicker.becomeFirstResponder()
        }
        else
        {
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
