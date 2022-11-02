//
//  Profile.swift
//  TawkIOSDeveloperTest
//
//  Created by Anthony Fullwood on 25/10/2022.
//

import Foundation
import CoreData

struct Profile: Codable{
    
    let id: Int
    let name: String
    let blog: String?
    let company: String?
    let avatar_url: String
    let followers: Int
    let following: Int
    
    
    //MARK: - Core Data CRUD Methods

    static func storeProfileOffline(profile: Profile,context: NSManagedObjectContext,user: StoredUser,completion: (Bool) ->()){
        
        
        user.profile?.name = profile.name
        user.profile?.followers = String(profile.followers)
        user.profile?.following = String(profile.following)
        
        
        if let safeBlog = profile.blog , let safeCompany = profile.company {
            user.profile?.blog = safeBlog
            user.profile?.company = safeCompany
        }
        
        
        do {
            
            try context.save()
            
            completion(true)
        } catch {
            
            print("Error saving context \(error)")
            completion(false)
        }
        
        
        
    }
    
    static func fetchStoredProfile(with id: Int64,context: NSManagedObjectContext) -> StoredUser? {
        
        let request: NSFetchRequest = StoredUser.fetchRequest()
        let predicateFormat = "id MATCHES %@"
        
        let predicate = NSPredicate(format: predicateFormat, id)
        
        request.predicate = predicate
        
        var profile: StoredUser?
        
        do{
            
            profile = try context.fetch(request).first
            
            
        }catch{
            print("Error fetching data \(error.localizedDescription)")
        }
        
        return profile
        
    }
    
    
    
    
}
