//
//  Project+CoreDataClass.swift
//  PlannerPlus
//
//  Created by jackson on 7/5/17.
//  Copyright © 2017 jackson. All rights reserved.
//
//

import Foundation
import CoreData
import CloudKit

@objc(Project)
public class Project: NSManagedObject {
    func updateFromRemote(_ remoteRecord: CKRecord)
    {
        self.name = remoteRecord.object(forKey: "projectName") as? String
        self.dueDate = remoteRecord.object(forKey: "projectDueDate") as? Date
        self.projectInfo = remoteRecord.object(forKey: "projectInfo") as? String
        self.subject = remoteRecord.object(forKey: "projectSubject") as? String
        self.projectType = remoteRecord.object(forKey: "projectType") as? String
        self.uuid = remoteRecord.object(forKey: "recordName") as? String
    }
    
    func updateToRemote(_ remoteRecord: CKRecord)
    {
        remoteRecord.setObject(self.name as CKRecordValue?, forKey: "projectName")
        remoteRecord.setObject(self.dueDate as CKRecordValue?, forKey: "projectDueDate")
        remoteRecord.setObject(self.projectInfo as CKRecordValue?, forKey: "projectInfo")
        remoteRecord.setObject(self.subject as CKRecordValue?, forKey: "projectSubject")
        remoteRecord.setObject(self.projectType as CKRecordValue?, forKey: "projectType")
        remoteRecord.setObject(self.uuid as CKRecordValue?, forKey: "recordName")
    }
}
