//
//  UserDataServices.swift
//  TawkIOSDeveloperTest
//
//  Created by Anthony Fullwood on 17/10/2022.
//

import Foundation
import UIKit
import CoreData


protocol UsersDataServicesDelegate{
    func didGetUsers(users:[StoredUser])
    func didGetMoreUser(users:[StoredUser])
}

class UsersDataServices{
    
    static let cache = NSCache<NSString,NSData>()
    var since: Int64 = 0
    var paginatingId: Int64?
    var delegate: UsersDataServicesDelegate?
    var mainContext: NSManagedObjectContext?
    
    
   
    
    func getUsers(with context: NSManagedObjectContext,pagination isPaginating: Bool,isAutoReconnecting:Bool){
        
        if !isPaginating{
            self.since = 0
        }
        
        let url = URL(string: "https://api.github.com/users?since=\(since)")!
        
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            
            if let error = error {
                
                print(error.localizedDescription)
                return
            }
            
            if let safeData = data{
                
                self.parseJSON(data: safeData,context: context,paginating: isPaginating,isAutoReconnecting: isAutoReconnecting)
                
            }
        }.resume()
        
    }
    
    private func parseJSON(data: Data,context: NSManagedObjectContext,paginating: Bool,isAutoReconnecting: Bool){
        
        
        let decoder = JSONDecoder()
        
        do{
            
            let decodedData = try decoder.decode([User].self, from: data)
            
            
            User.storeUsersOffline(decodedData,context, mainContext: mainContext!,paginating, isAutoReconnecting: isAutoReconnecting){ success in
                
                if success{
                    
                    if let mainContext = self.mainContext {
                        
                        if paginating{
                            self.getPaginatigStoredUsers(with: mainContext)
                        }else{
                            self.getStoredUsers(with: mainContext)
                        }
                        
                        
                    }
                }
            }
            
            
        }catch{
            print(error.localizedDescription)
            
        }
    }
    
    func getStoredUsers(with context: NSManagedObjectContext){
        
        
        self.mainContext = context
        
        
        
        if let users = User.fetchStoredUsers(with: context){
            
            self.delegate?.didGetUsers(users: users)
        }
        
        
    }
    
    func getPaginatigStoredUsers(with context: NSManagedObjectContext){
        
        
        if let paginatingUsers = User.fetchPaginatingUsers(with: since, context: context){
            
            self.delegate?.didGetMoreUser(users:  paginatingUsers)
            
        }
        
    }
}
