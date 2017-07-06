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
                    queuedChanges.updateValue(changeType, forKey: uuid) //Only delete
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
        
        for change in queuedChanges
        {
            switch change.value
            {
            case .insert:
                let remoteID = CKRecordID(recordName: change.key, zoneID: CKRecordZone.default().zoneID)
                
                let remoteRecord = CKRecord(recordType: "Project", recordID: remoteID)
                
                let newPredicate = NSPredicate(format: "uuid == %@", change.key)
                let newObject = fetchLocalObjects(withPredicate: newPredicate)!.first! as! Project
                
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
            case .delete:
                privateDatabase.delete(withRecordID: CKRecordID(recordName: change.key, zoneID: CKRecordZone.default().zoneID), completionHandler: { (recordID, error) -> Void in
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
                var updatePredicate = NSPredicate(format: "uuid == %@", change.key)
                let query = CKQuery(recordType: "Project", predicate: updatePredicate)
                privateDatabase.perform(query, inZoneWith: CKRecordZone.default().zoneID, completionHandler:
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
        if error == nil
        {
            NSLog("Fetched Objects To Update From CoreData...")
        }
        
        return fetchResults
    }
    
    override init()
    {
        super.init()
    }
}
