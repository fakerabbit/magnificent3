//
//  DataMgr.swift
//  MagnificentThree
//
//  Created by Mirko Justiniano on 9/7/15.
//  Copyright (c) 2015 MT. All rights reserved.
//

import Foundation
import CoreData
import UIKit

enum GameType: CustomStringConvertible {
    case arcade
    case rocky
    
    var description: String {
        switch self {
        case .arcade: return "Arcade"
        case .rocky: return "Rocky"
        }
    }
}

class DataMgr {
    
    fileprivate let kGameEntity = "Game",
                kGameEntityType = "type"
    
    var installTries: Int = 0
    
    // MARK: Public methods
    
    func storeGame(_ type: GameType, score: Int) {
        
        if let games = self.gamesForType(type) {
            if games.count >= 3 {
                
                if let maxGame = self.maxGameForType(type) {
                    if score > maxGame.score.intValue {
                        maxGame.date = Date()
                        maxGame.score = NSNumber(value: score as Int)
                    }
                }
                if let lowGame = self.lowGameForType(type) {
                    if score < lowGame.score.intValue {
                        lowGame.date = Date()
                        lowGame.score = NSNumber(value: score as Int)
                    }
                }
            }
            else {
                let game: DGame = NSEntityDescription.insertNewObject(forEntityName: kGameEntity,
                    into: self.managedObjectContext!) as! DGame;
                game.uuid = UUID().uuidString
                game.date = Date()
                game.type = NSNumber(value: type.hashValue as Int)
                game.score = NSNumber(value: score as Int)
            }
            self.saveContext()
        }
    }
    
    func gamesForType(_ type: GameType) -> [DGame]? {
        var games = [DGame]()
        
        if let entity: NSEntityDescription = NSEntityDescription.entity(forEntityName: kGameEntity, in: self.managedObjectContext!) {
            let request = NSFetchRequest<NSFetchRequestResult>()
            request.entity = entity
            request.predicate = NSPredicate(format: "%K == %@", argumentArray: [kGameEntityType, String(type.hashValue)])
            
            if let mutableFetchResults = try! self.managedObjectContext!.fetch(request) as [AnyObject]? {
                if mutableFetchResults.count > 0 {
                    games = mutableFetchResults as! [DGame]
                }
            }
        }
        
        return games
    }
    
    func lowGameForType(_ type: GameType) -> DGame? {
        
        var game: DGame? = nil
        
        if let games = self.gamesForType(type) {
            if games.count > 0 {
                game = games.first!
                for g: DGame in games {
                    if g.score.intValue <= game!.score.intValue {
                        game = g
                    }
                }
            }
        }
        
        return game
    }
    
    func maxGameForType(_ type: GameType) -> DGame? {
        
        var game: DGame? = nil
        
        if let games = self.gamesForType(type) {
            if games.count > 0 {
                game = games.first!
                for g: DGame in games {
                    if g.score.intValue >= game!.score.intValue {
                        game = g
                    }
                }
            }
        }
        
        return game
    }
    
    func lowestScoreForGame(_ type: GameType) -> Int {
        
        var score = 0
        if let game: DGame = self.lowGameForType(type) {
            score = game.score.intValue
        }
        
        return score
    }
    
    func highestScoreForGame(_ type: GameType) -> Int {
        
        var score = 0
        if let game: DGame = self.maxGameForType(type) {
            score = game.score.intValue
        }
        
        return score
    }
    
    // MARK: - Core Data stack
    
    lazy var applicationDocumentsDirectory: URL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.xxxx.ProjectName" in the application's documents Application Support directory.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1] 
        }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "MTData", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
        }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("MagnificentThree.sqlite")
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        
        if try! coordinator!.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil) == nil {
            if let err = error {
                if err.code == 134100 {
                    self.deleteStore()
                    self.installTries += 1
                    if (self.installTries < 2) {
                        coordinator = self.persistentStoreCoordinator // recreate the coordinator
                    }
                    else {
                        abort()
                    }
                }
            }
            else {
                self.deleteStore()
                self.displayWarning()
            }
            // Report any error we got.
            debugPrint("Unresolved error \(String(describing: error)), \(error!.userInfo)")
        }
        
        return coordinator
        }()
    
    lazy var managedObjectContext: NSManagedObjectContext? = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
        }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        if let moc = self.managedObjectContext {
            //var error: NSError? = nil
            if moc.hasChanges {
                moc.perform {
                    do {
                        try moc.save()
                    }
                    catch {
                        // Replace this implementation with code to handle the error appropriately.
                        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                        NSLog("Unresolved error ")
                        //abort()
                    }
                }
            }
       }
    }
    
    func deleteStore() {
        // Delete the old store
        let model: URL? = self.applicationDocumentsDirectory.appendingPathComponent("CurationLayer.sqlite")
        if let modelUrl = model {
            if FileManager.default.fileExists(atPath: modelUrl.path) {
                try! FileManager.default.removeItem(at: modelUrl)
            }
        }
    }
    
    func displayWarning() {
        let title = NSLocalizedString("Issue", comment: "")
        let message = NSLocalizedString("There was a problem installing the database, please restart the app.", comment: "")
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Ok", style: .default)
        alertController.addAction(cancelAction)
        let window = UIApplication
            .shared
            .connectedScenes
            .flatMap { ($0 as? UIWindowScene)?.windows ?? [] }
            .first { $0.isKeyWindow }
        guard let win = window, let rootController = win.rootViewController else { return }
        alertController.show(rootController, sender: nil)
    }
    
    /**
     * Singleton
     */
    class var sharedInstance: DataMgr {
        struct Singleton {
            static let instance = DataMgr()
        }
        return Singleton.instance
    }
}
