//
//  ProfileViewModel.swift
//  TawkIOSDeveloperTest
//
//  Created by Anthony Fullwood on 25/10/2022.
//

import Foundation
import UIKit
import CoreData


protocol ProfileViewModelDelegate{
    func didUpdateNotes()
}

class ProfileViewModel{

    var profileData: StoredUser?
    var userImage: UIImage?
    var context: NSManagedObjectContext?
    
    var delegate: ProfileViewModelDelegate?
    
    func getName() -> String{
        
        if let name = profileData?.profile?.name {
            return name
        }else{
            return ""
        }
    }
    
   func getImage() -> UIImage?{
        
       if let safeUserImage = userImage{
           
           return safeUserImage
           
       }else{
           
           return UIImage(systemName: "person.fill")?.withTintColor(UIColor.systemTeal, renderingMode: .alwaysOriginal)
       }
    }
    
    
    func getBlog() -> String{
        
        if let blog = profileData?.profile?.blog {
            return blog
        }else{
            return "n/a"
        }
    }
    
    func getCompany() -> String{
        
        if let company = profileData?.profile?.company {
            return company
        }else{
            return "n/a"
        }
    }
    
    func getFollowers() -> String{
        
        if let followers = profileData?.profile?.followers {
            return followers
        }else{
            return "0"
        }
    }
    
    func getFollowing() -> String{
        
        if let following = profileData?.profile?.following {
            return following
        }else{
            return "0"
        }
    }
    
    func getNotes() -> String{
        
        if let notes = profileData?.notes {
            return notes
        }else{
            return ""
        }
    }
    
    
    func saveNotes(notes: String) {
        
        profileData?.notes = notes
        
        do{
            try context?.save()
            self.delegate?.didUpdateNotes()
            
        }catch{
            print("Error saving notes: \(error.localizedDescription)")
        
        }
    }
}
