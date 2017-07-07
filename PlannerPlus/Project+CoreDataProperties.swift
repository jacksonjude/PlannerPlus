//
//  Project+CoreDataProperties.swift
//  PlannerPlus
//
//  Created by jackson on 7/5/17.
//  Copyright © 2017 jackson. All rights reserved.
//
//

import Foundation
import CoreData


extension Project {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Project> {
        return NSFetchRequest<Project>(entityName: "Project")
    }

    @NSManaged public var createdAt: Date?
    @NSManaged public var dueDate: Date?
    @NSManaged public var name: String?
    @NSManaged public var projectInfo: String?
    @NSManaged public var projectSubject: String?
    @NSManaged public var projectType: String?
    @NSManaged public var uuid: String?

}
