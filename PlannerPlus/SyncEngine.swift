//
//  SyncEngine.swift
//  PlannerPlus
//
//  Created by jackson on 7/5/17.
//  Copyright © 2017 jackson. All rights reserved.
//

import Foundation
import CoreData
import CloudKit
import UIKit

class SyncEngine: NSObject
{
    var managedObjectContext: NSManagedObjectContext = (UIApplication.shared.delegate! as! AppDelegate).persistentContainer.viewContext
    
    let projectZone = CKRecordZone(zoneName: "ProjectZone")
    var currentChangeToken: CKServerChangeToken?
    var isReceivingFromServer = false
    
    var queuedChanges = Dictionary<String, NSFetchedResultsChangeType>()
    
    func addToLocalChanges(withUUID uuid: String, withChangeType changeType: NSFetchedResultsChangeType)
    {
        if queuedChanges.index(forKey: uuid) != nil
        {
            let queuedChangeForObject = queuedChanges[queuedChanges.index(forKey: uuid)!]
            switch queuedChangeForObject.value
            {
            case .delete:
            break //Should never call, already in queue to delete object
            case .insert:
                if changeType == .delete
                {
                    queuedChanges.removeValue(forKey: uuid) //If inserting and deleting are both in queue, don't do either
                }
                if changeType == .update
                {
                    //Don't need to insert and update, inserting is enough
                }
            case .update:
                if changeType == .delete
                {
                    queuedChanges.updateValue(changeType, forKey: uuid) //Only delete if anything else is in queue
                }
            case .move:
                break
            }
        }
        else
        {
            queuedChanges.updateValue(changeType, forKey: uuid)
        }
    }
    
    func syncData()
    {
        let privateDatabase = CKContainer.default().privateCloudDatabase
        
        print("↑ - Syncing Data to Cloud")
        
        for change in queuedChanges
        {
            switch change.value
            {
            case .insert:
                print(" ↑ - Inserting: \(change.key)")
                
                let remoteID = CKRecordID(recordName: change.key, zoneID: projectZone.zoneID)
                
                let remoteRecord = CKRecord(recordType: "Project", recordID: remoteID)
                
                let newPredicate = NSPredicate(format: "uuid == %@", change.key)
                if let newObject = fetchLocalObjects(withPredicate: newPredicate)?.first as? Project
                {
                    newObject.updateToRemote(remoteRecord)
                    
                    privateDatabase.save(remoteRecord, completionHandler: { (record, error) -> Void in
                        if (error != nil) {
                            print("Error: \(String(describing: error))")
                        }
                        else
                        {
                            self.queuedChanges.removeValue(forKey: change.key)
                        }
                    })
                }
            case .delete:
                print(" ↑ - Deleting: \(change.key)")
                privateDatabase.delete(withRecordID: CKRecordID(recordName: change.key, zoneID: projectZone.zoneID), completionHandler: { (recordID, error) -> Void in
                    if error != nil
                    {
                        print("Error: \(String(describing: error))")
                    }
                    else
                    {
                        self.queuedChanges.removeValue(forKey: change.key)
                    }
                })
            case .update:
                print(" ↑ - Updating: \(change.key)")
                var updatePredicate = NSPredicate(format: "recordName == %@", change.key)
                let query = CKQuery(recordType: "Project", predicate: updatePredicate)
                privateDatabase.perform(query, inZoneWith: projectZone.zoneID, completionHandler:
                    { (results, error) -> Void in
                        if results?.first != nil
                        {
                            updatePredicate = NSPredicate(format: "uuid == %@", change.key)
                            let remoteRecordToUpdate = results!.first
                            let localProjectToUpdate = self.fetchLocalObjects(withPredicate: updatePredicate)!.first as! Project
                            localProjectToUpdate.updateToRemote(remoteRecordToUpdate!)
                            
                            privateDatabase.save(remoteRecordToUpdate!, completionHandler: { (record, error) -> Void in
                                if (error != nil) {
                                    print("Error: \(String(describing: error))")
                                }
                                else
                                {
                                    self.queuedChanges.removeValue(forKey: change.key)
                                }
                            })
                        }
                })
            case .move:
                break
            }
        }
        
        print("↑ - Finished Syncing Data to Cloud")
    }
    
    func fetchLocalObjects(withPredicate predicate: NSPredicate) -> [AnyObject]?
    {
        let fetchRequest: NSFetchRequest<Project> = Project.fetchRequest()
        fetchRequest.predicate = predicate
        
        let fetchResults: [AnyObject]?
        var error: NSError? = nil
        
        do {
            fetchResults = try self.managedObjectContext.fetch(fetchRequest)
        } catch let error1 as NSError {
            error = error1
            fetchResults = nil
            NSLog("An Error Occored:", error!)
        } catch {
            fatalError()
        }
        
        return fetchResults
    }
    
    //Very forking picky about how it receives notifications... Wouldn't work unless should badge is set to true
    func setupRemoteSubscriptions()
    {
        let privateDatabase = CKContainer.default().privateCloudDatabase as CKDatabase
        
        let projectSubscription = CKQuerySubscription(recordType: "Project", predicate: NSPredicate(value: true), options: [.firesOnRecordCreation, .firesOnRecordUpdate, .firesOnRecordDeletion])
        
        let projectNotificationInfo = CKNotificationInfo()
        projectNotificationInfo.shouldBadge = true
        projectNotificationInfo.alertBody = ""
        projectSubscription.notificationInfo = projectNotificationInfo
        
        let operation = CKModifySubscriptionsOperation(subscriptionsToSave: [projectSubscription], subscriptionIDsToDelete: nil)
        
        operation.modifySubscriptionsCompletionBlock = { (subscriptions, str, error) in
            if error != nil
            {
                print("Error: \(error.debugDescription)")
            }
        }
        
        privateDatabase.add(operation)
    }
    
    func fetchChangesFromCloud()
    {
        print("↓ - Fetching Changes from Cloud")
        
        isReceivingFromServer = true
        
        let zoneChangeoptions = CKFetchRecordZoneChangesOptions()
        zoneChangeoptions.previousServerChangeToken = currentChangeToken
        
        let fetchRecordChangesOperation = CKFetchRecordZoneChangesOperation(recordZoneIDs: [projectZone.zoneID], optionsByRecordZoneID: [projectZone.zoneID:zoneChangeoptions])
        fetchRecordChangesOperation.fetchAllChanges = true
        
        fetchRecordChangesOperation.recordChangedBlock = {(record) in
            let updateLocalObjectPredicate = NSPredicate(format: "uuid == %@", record.recordID.recordName)
            if let recordToUpdate = self.fetchLocalObjects(withPredicate: updateLocalObjectPredicate)?.first as? Project
            {
                recordToUpdate.updateFromRemote(record)
                
                print(" ↓ - Updating: \(recordToUpdate.uuid!)")
            }
            else
            {
                let newProject = Project(context: self.managedObjectContext)
                newProject.updateFromRemote(record)
                
                print(" ↓ - Inserting: \(newProject.uuid ?? "N/A")")
            }
            
            OperationQueue.main.addOperation {
                (UIApplication.shared.delegate as! AppDelegate).saveContext()
            }
        }
        
        fetchRecordChangesOperation.recordWithIDWasDeletedBlock = {(recordID, string) in
            let deleteLocalObjectPredicate = NSPredicate(format: "uuid == %@", recordID.recordName)
            let recordToDelete = self.fetchLocalObjects(withPredicate: deleteLocalObjectPredicate)?.first
            if recordToDelete != nil
            {
                print(" ↓ - Deleting: \(recordToDelete!.uuid! ?? "N/A")")
                
                OperationQueue.main.addOperation {
                    self.managedObjectContext.delete(recordToDelete as! NSManagedObject)
                    (UIApplication.shared.delegate as! AppDelegate).saveContext()
                }
            }
        }
        
        fetchRecordChangesOperation.recordZoneFetchCompletionBlock = {(recordZoneID, serverChangeToken, data, bool, error) in
            if error != nil
            {
                print("Error: \(String(describing: error))")
            }
            else
            {
                self.currentChangeToken = serverChangeToken
                UserDefaults.standard.set(NSKeyedArchiver.archivedData(withRootObject: self.currentChangeToken as Any), forKey: "currentChangeToken")
            }
        }
        
        fetchRecordChangesOperation.completionBlock = { () in
            self.isReceivingFromServer = false
            
            print("↓ - Finished Fetching Changes from Cloud")
            
            OperationQueue.main.addOperation {
                NotificationCenter.default.post(name: Notification.Name(rawValue: "finishedFetchingFromCloud"), object: nil)
            }
        }
        
        let privateDatabase = CKContainer.default().privateCloudDatabase as CKDatabase
        privateDatabase.add(fetchRecordChangesOperation)
    }
    
    override init()
    {
        super.init()
        
        setupRemoteSubscriptions()
        
        if (UIApplication.shared.delegate as! AppDelegate).firstLaunch
        {
            
        }
        else
        {
            if let changeToken = UserDefaults.standard.object(forKey: "currentChangeToken")
            {
                currentChangeToken = NSKeyedUnarchiver.unarchiveObject(with: changeToken as! Data) as? CKServerChangeToken
                
            }
        }
    }
}
