//
//  DetailViewController.swift
//  PlannerPlus
//
//  Created by jackson on 7/4/17.
//  Copyright © 2017 jackson. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var projectNavigationItem: UINavigationItem!
    @IBOutlet weak var projectInfo: UITextView!
    @IBOutlet weak var projectSubjectLabel: UILabel!
    @IBOutlet weak var projectTypeLabel: UILabel!
    

    func configureView() {
        // Update the user interface for the detail item.
        if let detail = detailItem {
            if let textView = projectInfo, detail.projectInfo != nil
            {
                textView.text = detail.projectInfo
            }
            if let navigationItem = projectNavigationItem, detail.name != nil
            {
                navigationItem.title = detail.name
            }
            if let subjectLabel = projectSubjectLabel, detail.projectSubject != nil
            {
                subjectLabel.text = detail.projectSubject
            }
            if let typeLabel = projectTypeLabel, detail.projectType != nil
            {
                typeLabel.text = detail.projectType
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        projectNavigationItem.rightBarButtonItem = editButtonItem
        // Do any additional setup after loading the view, typically from a nib.
        configureView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(setProjectType), name: Notification.Name(rawValue: "selectedProjectType"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(setProjectSubject), name: Notification.Name(rawValue: "selectedProjectSubject"), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        detailItem!.projectInfo = projectInfo.text
        
        (UIApplication.shared.delegate as! AppDelegate).syncEngine?.addToLocalChanges(withUUID: detailItem!.uuid!, withChangeType: .update)
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        if editing
        {
            projectInfo.isEditable = true
            NotificationCenter.default.post(name: Notification.Name(rawValue: "toggleEditing"), object: nil)
        }
        else
        {
            projectInfo.isEditable = false
            NotificationCenter.default.post(name: Notification.Name(rawValue: "toggleEditing"), object: nil)
        }
    }
    
    @objc func setProjectType(notification: Notification)
    {
        let projectType = notification.object as! String
        detailItem!.projectType = projectType
        
        configureView()
    }
    
    @objc func setProjectSubject(notification: Notification)
    {
        let projectSubject = notification.object as! String
        detailItem!.projectSubject = projectSubject
        
        configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    var detailItem: Project? {
        didSet {
            // Update the view.
            configureView()
        }
    }
}

