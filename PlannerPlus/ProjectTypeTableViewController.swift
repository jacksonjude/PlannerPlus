//
//  ProjectTypeTableViewController.swift
//  PlannerPlus
//
//  Created by jackson on 7/6/17.
//  Copyright © 2017 jackson. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class ProjectTypeTableViewController: UITableViewController
{
    var projectTypeArray = Array<String>()
    var projectSubjectArray = Array<String>()
    
    override func viewDidLoad() {
        //navigationItem.leftBarButtonItem = editButtonItem
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertNewType))
        navigationItem.rightBarButtonItem = addButton
        
        if let projectTypeArray = UserDefaults.standard.object(forKey: "projectTypes") as? Array<String>
        {
            self.projectTypeArray = projectTypeArray
        }
        
        if let projectSubjectArray = UserDefaults.standard.object(forKey: "projectSubjects") as? Array<String>
        {
            self.projectSubjectArray = projectSubjectArray
        }
        
        tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        UserDefaults.standard.set(self.projectTypeArray, forKey: "projectTypes")
        UserDefaults.standard.set(self.projectSubjectArray, forKey: "projectSubjects")
    }
    
    @objc func insertNewType()
    {
        let typeSubjectAlert = UIAlertController(title: "New Type or Subject", message: "Create a new subject (ie: Biology) or project type (ie: Homework, Project)", preferredStyle: .alert)
        typeSubjectAlert.addTextField { (textFeild) in
            textFeild.placeholder = "Name"
        }
        typeSubjectAlert.addAction(UIAlertAction(title: "Type", style: .default, handler: { (alert) in
            let typeName = typeSubjectAlert.textFields![0].text
            
            if typeName != nil
            {
                self.projectTypeArray.append(typeName!)
                
                self.tableView.reloadData()
            }
        }))
        
        typeSubjectAlert.addAction(UIAlertAction(title: "Subject", style: .default, handler: { (alert) in
            let subjectName = typeSubjectAlert.textFields![0].text
            
            if subjectName != nil
            {
                self.projectSubjectArray.append(subjectName!)
                
                UserDefaults.standard.set(self.projectSubjectArray, forKey: "projectSubjects")
                
                self.tableView.reloadData()
            }
        }))
        
        typeSubjectAlert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (alert) in
            
        }))
        
        self.present(typeSubjectAlert, animated: true) {
            
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section
        {
        case 0:
            return "Type"
        case 1:
            return "Subject"
        default:
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return projectTypeArray.count
        case 1:
            return projectSubjectArray.count
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TypeCell", for: indexPath)
        switch indexPath.section {
        case 0:
            cell.textLabel!.text = projectTypeArray[indexPath.row]
        case 1:
            cell.textLabel!.text = projectSubjectArray[indexPath.row]
        default:
            break
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            switch indexPath.section
            {
            case 0:
                projectTypeArray.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            case 1:
                projectSubjectArray.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            default:
                break
            }
        }
    }
}
