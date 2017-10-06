//
//  DetailViewController.swift
//  PlannerPlus
//
//  Created by jackson on 7/4/17.
//  Copyright © 2017 jackson. All rights reserved.
//

import UIKit
import CloudKit

class DetailViewController: UIViewController {

    @IBOutlet weak var projectNavigationItem: UINavigationItem!
    @IBOutlet weak var projectInfo: UITextView!
    @IBOutlet weak var projectSubjectLabel: UILabel!
    @IBOutlet weak var projectTypeLabel: UILabel!
    @IBOutlet weak var projectDueDateLabel: UILabel!
        
    let kNone = 0
    let kShow = 1
    let kHide = 2
    
    var detailIsEditing = false

    @objc func configureView() {
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
            if let dueDateLabel = projectDueDateLabel, detail.dueDate != nil
            {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MM-dd hh:mm"
                dueDateLabel.text = dateFormatter.string(from: detail.dueDate!)
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
        NotificationCenter.default.addObserver(self, selector: #selector(setProjectDueDate), name: Notification.Name(rawValue: "selectedDueDate"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(fetchedNewCloudUpdates), name: Notification.Name(rawValue: "finishedFetchingFromCloud"), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if detailItem != nil
        {
            (UIApplication.shared.delegate as! AppDelegate).syncEngine?.addToLocalChanges(withUUID: detailItem!.uuid!, withChangeType: .update)
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
        }
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        if editing
        {
            projectInfo.isEditable = true
            NotificationCenter.default.post(name: Notification.Name(rawValue: "togglePicker"), object: [kShow, detailItem?.projectType as Any, detailItem?.projectSubject as Any])
            
            //projectNavigationItem.leftBarButtonItem = UIBarButtonItem(title: "Share", style: .plain, target: self, action: #selector(shareRecordButtonPressed))
            
            detailIsEditing = true
        }
        else
        {
            projectInfo.isEditable = false
            detailItem!.projectInfo = projectInfo.text
            NotificationCenter.default.post(name: Notification.Name(rawValue: "togglePicker"), object: [kHide])
            
            projectNavigationItem.leftBarButtonItem = projectNavigationItem.backBarButtonItem
            
            (UIApplication.shared.delegate as! AppDelegate).syncEngine!.addToLocalChanges(withUUID: detailItem!.uuid!, withChangeType: .update)
            
            detailIsEditing = false
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
    
    @objc func setProjectDueDate(notification: Notification)
    {
        let projectDueDate = notification.object as! Date
        detailItem!.dueDate = projectDueDate
        
        configureView()
    }
    
    @IBAction func togglePickerToShow()
    {
        /*if pickerToShow == kLabels
        {
            pickerToShow = kDueDate
            pickerButton.setTitle("Due Date", for: .normal)
            NotificationCenter.default.post(name: Notification.Name(rawValue: "togglePicker"), object: [pickerToShow, detailItem?.projectType as Any, detailItem?.projectSubject as Any])
            self.view.sendSubview(toBack: self.view.viewWithTag(617)!)
        }
        else if pickerToShow == kDueDate
        {
            pickerToShow = kLabels
            pickerButton.setTitle("Labels", for: .normal)
            NotificationCenter.default.post(name: Notification.Name(rawValue: "togglePicker"), object: [pickerToShow, detailItem?.projectType as Any, detailItem?.projectSubject as Any])
            self.view.sendSubview(toBack: self.view.viewWithTag(616)!)
        }*/
    }
    
    @objc func fetchedNewCloudUpdates()
    {
        if !detailIsEditing
        {
            configureView()
        }
    }
    
    @objc func shareRecordButtonPressed()
    {
        let projectZone = CKRecordZone(zoneName: "ProjectZone")
        let privateDatabase = CKContainer.default().privateCloudDatabase as CKDatabase
        
        let sharePredicate = NSPredicate(format: "recordName == %@", detailItem!.uuid!)
        let query = CKQuery(recordType: "Project", predicate: sharePredicate)
        privateDatabase.perform(query, inZoneWith: projectZone.zoneID, completionHandler:
            { (results, error) -> Void in
                if results != nil
                {
                    
                    let controller = UICloudSharingController {(controller, prepareCompletionHandler) in
                        
                        let share = CKShare(rootRecord: results!.first!)
                        
                        share[CKShareTitleKey] = results!.first!.object(forKey: "projectName")
                        share.publicPermission = .none
                        
                        let modifyRecordsOperation = CKModifyRecordsOperation(
                            recordsToSave: [results!.first!, share],
                            recordIDsToDelete: nil)
                        
                        modifyRecordsOperation.modifyRecordsCompletionBlock = {
                            records, recordIDs, error in
                            if error != nil {
                                print(error!.localizedDescription)
                            }
                            prepareCompletionHandler(share,
                                                     CKContainer.default(), error)
                        }
                        privateDatabase.add(modifyRecordsOperation)
                    }
                    
                    controller.popoverPresentationController?.barButtonItem = self.projectNavigationItem.leftBarButtonItem
                    
                    self.present(controller, animated: true)
                }
        })
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

