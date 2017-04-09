//
//  CoreDataRepository+Tasks.swift
//  Jirassic
//
//  Created by Cristian Baluta on 02/04/2017.
//  Copyright © 2017 Imagin soft. All rights reserved.
//

import Foundation
import CoreData

extension CoreDataRepository: RepositoryTasks {
    
    func queryTasks (_ page: Int, completion: @escaping ([Task], NSError?) -> Void) {
        
        let predicate = NSPredicate(format: "markedForDeletion == NO")
        let sortDescriptors = [NSSortDescriptor(key: "endDate", ascending: true)]
        let results: [CTask] = queryWithPredicate(predicate, sortDescriptors: sortDescriptors)
        let tasks = tasksFromCTasks(results)
        
        completion(tasks, nil)
    }
    
    func queryTasksInDay (_ day: Date) -> [Task] {
        
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "endDate >= %@ AND endDate <= %@", day.startOfDay() as CVarArg, day.endOfDay() as CVarArg),
            NSPredicate(format: "markedForDeletion == NO")
        ])
        let sortDescriptors = [NSSortDescriptor(key: "endDate", ascending: true)]
        let results: [CTask] = queryWithPredicate(compoundPredicate, sortDescriptors: sortDescriptors)
        let tasks = tasksFromCTasks(results)
        
        return tasks
    }
    
    func queryTasksInDay (_ day: Date, completion: @escaping ([Task], NSError?) -> Void) {
        completion(queryTasksInDay(day), nil)
    }
    
    func queryUnsyncedTasks() -> [Task] {
        
        let predicate = NSPredicate(format: "lastModifiedDate == nil AND markedForDeletion == NO")
        let results: [CTask] = queryWithPredicate(predicate, sortDescriptors: nil)
        let tasks = tasksFromCTasks(results)
        
        return tasks
    }
    
    func queryDeletedTasks (_ completion: @escaping ([Task]) -> Void) {
        
        let predicate = NSPredicate(format: "markedForDeletion == YES")
        let results: [CTask] = queryWithPredicate(predicate, sortDescriptors: nil)
        let tasks = tasksFromCTasks(results)
        
        completion(tasks)
    }
    
    func queryUpdates (sinceDate: Date, completion: @escaping ([Task], [String], NSError?) -> Void) {
        
        let predicate = NSPredicate(format: "lastModifiedDate > %@ AND markedForDeletion == NO", sinceDate as CVarArg)
        let results: [CTask] = queryWithPredicate(predicate, sortDescriptors: nil)
        let tasks = tasksFromCTasks(results)
        
        completion(tasks, [], nil)
    }
    
    func deleteTask (_ task: Task, forceDelete: Bool, completion: @escaping ((_ success: Bool) -> Void)) {
        
        guard let context = managedObjectContext else {
            return
        }
        
        let ctask = ctaskFromTask(task)
        if forceDelete {
            context.delete(ctask)
        } else {
            ctask.markedForDeletion = NSNumber(value: true)
        }
        saveContext()
        completion(true)
    }
    
    func deleteTask (objectId: String, completion: @escaping ((_ success: Bool) -> Void)) {
        
    }
    
    func saveTask (_ task: Task, completion: @escaping ((_ task: Task) -> Void)) {
        
        let ctask = ctaskFromTask(task)
        saveContext()
        
        completion( taskFromCTask(ctask))
    }
}

extension CoreDataRepository {
    
    fileprivate func taskFromCTask (_ ctask: CTask) -> Task {
        
        return Task(lastModifiedDate: ctask.lastModifiedDate,
                    startDate: ctask.startDate,
                    endDate: ctask.endDate!,
                    notes: ctask.notes,
                    taskNumber: ctask.taskNumber,
                    taskTitle: ctask.taskTitle,
                    taskType: TaskType(rawValue: ctask.taskType!.intValue)!,
                    objectId: ctask.objectId!
        )
    }
    
    fileprivate func tasksFromCTasks (_ ctasks: [CTask]) -> [Task] {
        
        var tasks = [Task]()
        for ctask in ctasks {
            tasks.append(self.taskFromCTask(ctask))
        }
        
        return tasks
    }
    
    fileprivate func ctaskFromTask (_ task: Task) -> CTask {
        
        let taskPredicate = NSPredicate(format: "objectId == %@", task.objectId)
        let tasks: [CTask] = queryWithPredicate(taskPredicate, sortDescriptors: nil)
        var ctask: CTask? = tasks.first
        if ctask == nil {
            ctask = NSEntityDescription.insertNewObject(forEntityName: String(describing: CTask.self),
                                                        into: managedObjectContext!) as? CTask
            ctask?.objectId = task.objectId
        }
        
        return updatedCTask(ctask!, withTask: task)
    }
    
    // Update only updatable properties. objectId can't be updated
    fileprivate func updatedCTask (_ ctask: CTask, withTask task: Task) -> CTask {
        
        ctask.taskNumber = task.taskNumber
        ctask.taskType = NSNumber(value: task.taskType.rawValue)
        ctask.notes = task.notes
        ctask.startDate = task.startDate
        ctask.endDate = task.endDate
        ctask.lastModifiedDate = task.lastModifiedDate
        
        return ctask
    }
}
