//
//  Persistence.swift
//  Hours
//
//  Created by Ariel Steiner on 08/12/2021.
//

import CoreData

class PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        for i in 0..<15 {
            let newItem = Item(context: viewContext)
            let day = Calendar.current.date(byAdding: DateComponents(day: -i), to: Date())!
            if Int.random(in: 1...3) != 1 {
                newItem.begin = day - TimeInterval(Int.random(in: 10...300)*60)
            }
            if Int.random(in: 1...3) != 1 {
                newItem.end = day + TimeInterval(Int.random(in: 10...300)*60)
            }
            newItem.day = day
        }
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer
    var writeContext : NSManagedObjectContext!

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Hours")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { [self] (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
            container.viewContext.automaticallyMergesChangesFromParent = true
            writeContext = container.newBackgroundContext()
        })
    }

    func insertBeginWork(time : Date = Date()) {
        let context = writeContext!
        context.perform {
            let newEntry = Item(context: context)
            newEntry.day = time
            newEntry.begin = time
            do {
                try context.save()
            } catch {
                logger.log("Couldn't insert entry time! \(time). \(error.localizedDescription)")
            }
        }
    }

    func insertEndWork(time : Date = Date()) {
        let context = writeContext!
        context.perform {
            let request : NSFetchRequest<Item> = {
                let request = Item.fetchRequest()
                request.sortDescriptors = [NSSortDescriptor(keyPath: \Item.begin, ascending: false)]
                request.fetchLimit = 1
                return request
            }()
            let item : Item
            if let latest = (try? context.fetch(request))?.first, let _ = latest.begin {
                item = latest
            } else {
                logger.log("Warning: start time missing or couldn't be fetched. inserting end time alone")
                item = Item(context: context)
                item.day = time
            }
            item.end = time

            do {
                try context.save()
            }
            catch {
                logger.log("Couldn't insert exit time! \(time). \(error.localizedDescription)")
            }
        }
    }
}
