//
//  User.swift
//  TawkIOSDeveloperTest
//
//  Created by Anthony Fullwood on 17/10/2022.
//

import Foundation
import UIKit
import CoreData



struct User: Codable{
    
    let id: Int
    let login: String
    let avatar_url: String
    let type: String
    
    //MARK: - Core Data CRUD Methods
    static func storeUsersOffline(_ userList: [User],_ backgroundContext: NSManagedObjectContext,mainContext: NSManagedObjectContext,_ isPaginating: Bool,isAutoReconnecting: Bool,_ completion: (Bool) ->()){
        
        
        if fetchStoredUsers(with: backgroundContext) != nil && !isPaginating{
            
            deleteStoredUsers(with: backgroundContext)
        }
        
        if isAutoReconnecting{
            deleteStoredUsers(with: mainContext)
        }
        
        
        for user in userList {
            
            DispatchQueue.global(qos: .background).async {
                
                backgroundContext.perform {
                    
                    let newStoredUser = StoredUser(context: backgroundContext)
                    newStoredUser.login = user.login
                    newStoredUser.id = Int64(user.id)
                    newStoredUser.avatar_url = user.avatar_url
                    newStoredUser.type = user.type
                    
                    let newStoredProfile = StoredProfile(context: backgroundContext)
                    newStoredProfile.id = newStoredUser.id
                    
                    newStoredUser.profile = newStoredProfile
                    
                    do {
                        
                        try backgroundContext.save()
                        
                        
                    } catch {
                        
                        
                        print("Error saving context \(error)")
                    }
                    
                }
            }
            
            
            do{
                let data = try Data(contentsOf: URL(string: user.avatar_url)!)
                UsersDataServices.cache.setObject(data as NSData, forKey: user.avatar_url as NSString)
                
            }catch{
                print(error.localizedDescription)
            }
            
        }
        
        completion(true)
        
    }
    
    static func fetchStoredUsers(with context: NSManagedObjectContext) -> [StoredUser]? {
        
        let request: NSFetchRequest = StoredUser.fetchRequest()
        let sort = NSSortDescriptor(key: "id", ascending: true)
        request.sortDescriptors = [sort]
        var users: [StoredUser]?
        
        do{
            users = try context.fetch(request)
            
        }catch{
            print("Error fetching data \(error.localizedDescription)")
        }
        
        return users
    }
    
    static func fetchPaginatingUsers(with id: Int64,context: NSManagedObjectContext) -> [StoredUser]?{
        
        let request: NSFetchRequest = StoredUser.fetchRequest()
        let sort = NSSortDescriptor(key: "id", ascending: true)
        request.sortDescriptors = [sort]
        
        var users: [StoredUser]?
        var paginatingUsers : [StoredUser] = []
        
        
        do{
            
            users = try context.fetch(request)
            
            for user in users!  where user.id > id{
                
                
                paginatingUsers.append(user)
                
            }
            
            
            
        }catch{
            print("Error fetching data \(error.localizedDescription)")
        }
        
        return paginatingUsers
    }
    
    
    static func deleteStoredUsers(with context: NSManagedObjectContext){
        
        let request: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "StoredUser")
        let deleteRequest =  NSBatchDeleteRequest(fetchRequest: request)
        
        do{
            try context.execute(deleteRequest)
            
        }catch{
            print("Error Deleting data \(error.localizedDescription)")
        }
        
        
    }
    
}
