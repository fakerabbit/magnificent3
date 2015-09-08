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

enum GameType: Printable {
    case Arcade
    case Rocky
    
    var description: String {
        switch self {
        case .Arcade: return "Arcade"
        case .Rocky: return "Rocky"
        }
    }
}

class DataMgr {
    
    private let kGameEntity = "Game"
    
    var installTries: Int = 0
    
    // MARK: Public methods
    
    func storeGame(type: GameType, score: Int) {
        
        if let games = self.gamesForType(type) {
            if games.count >= 3 {
                
                if let maxGame = self.maxGameForType(type) {
                    if score > maxGame.score.integerValue {
                        maxGame.date = NSDate()
                        maxGame.score = NSNumber(integer: score)
                    }
                }
                if let lowGame = self.lowGameForType(type) {
                    if score < lowGame.score.integerValue {
                        lowGame.date = NSDate()
                        lowGame.score = NSNumber(integer: score)
                    }
                }
            }
            else {
                var game: DGame = NSEntityDescription.insertNewObjectForEntityForName(kGameEntity,
                    inManagedObjectContext: self.managedObjectContext!) as! DGame;
                game.uuid = NSUUID().UUIDString
                game.date = NSDate()
                game.type = NSNumber(integer: type.hashValue)
                game.score = NSNumber(integer: score)
            }
            self.saveContext()
        }
    }
    
    func gamesForType(type: GameType) -> [DGame]? {
        var games = [DGame]()
        
        if let entity: NSEntityDescription = NSEntityDescription.entityForName(kGameEntity, inManagedObjectContext: self.managedObjectContext!) {
            var request: NSFetchRequest = NSFetchRequest()
            request.entity = entity
            
            if let mutableFetchResults = self.managedObjectContext!.executeFetchRequest(request, error: nil) {
                if mutableFetchResults.count > 0 {
                    games = mutableFetchResults as! [DGame]
                }
            }
        }
        
        return games
    }
    
    func lowGameForType(type: GameType) -> DGame? {
        
        var game: DGame? = nil
        
        if let games = self.gamesForType(type) {
            if games.count > 0 {
                game = games.first!
                for g: DGame in games {
                    println(g)
                    if g.score.integerValue <= game!.score.integerValue {
                        game = g
                    }
                }
            }
        }
        
        return game
    }
    
    func maxGameForType(type: GameType) -> DGame? {
        
        var game: DGame? = nil
        
        if let games = self.gamesForType(type) {
            if games.count > 0 {
                game = games.first!
                for g: DGame in games {
                    println(g)
                    if g.score.integerValue >= game!.score.integerValue {
                        game = g
                    }
                }
            }
        }
        
        return game
    }
    
    func lowestScoreForGame(type: GameType) -> Int {
        
        var score = 0
        if let game: DGame = self.lowGameForType(type) {
            score = game.score.integerValue
        }
        
        return score
    }
    
    func highestScoreForGame(type: GameType) -> Int {
        
        var score = 0
        if let game: DGame = self.maxGameForType(type) {
            score = game.score.integerValue
        }
        
        return score
    }
    
    // MARK: - Core Data stack
    
    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.xxxx.ProjectName" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1] as! NSURL
        }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("MTData", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
        }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("MagnificentThree.sqlite")
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        if coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil, error: &error) == nil {
            if let err = error {
                if err.code == 134100 {
                    self.deleteStore()
                    self.installTries++
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
            println("Unresolved error \(error), \(error!.userInfo)")
        }
        
        return coordinator
        }()
    
    lazy var managedObjectContext: NSManagedObjectContext? = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
        }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        if let moc = self.managedObjectContext {
            var error: NSError? = nil
            if moc.hasChanges && !moc.save(&error) {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                NSLog("Unresolved error \(error), \(error!.userInfo)")
                abort()
            }
       }
    }
    
    func deleteStore() {
        // Delete the old store
        let model: NSURL? = self.applicationDocumentsDirectory.URLByAppendingPathComponent("CurationLayer.sqlite")
        if let modelUrl = model {
            if NSFileManager.defaultManager().fileExistsAtPath(modelUrl.path!) {
                NSFileManager.defaultManager().removeItemAtURL(modelUrl, error: nil)
            }
        }
    }
    
    func displayWarning() {
        let title = NSLocalizedString("Issue", comment: "")
        let message = NSLocalizedString("There was a problem installing the database, please restart the app.", comment: "")
        let cancel = NSLocalizedString("Ok", comment: "")
        let alert: UIAlertView = UIAlertView(title: title, message: message, delegate: nil, cancelButtonTitle: cancel)
        alert.show()
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
