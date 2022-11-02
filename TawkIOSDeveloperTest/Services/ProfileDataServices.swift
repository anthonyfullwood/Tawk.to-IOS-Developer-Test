//
//  ProfileDataServices.swift
//  TawkIOSDeveloperTest
//
//  Created by Anthony Fullwood on 25/10/2022.
//

import Foundation
import CoreData



protocol ProfileDataServicesDelegate{
    func didGetProfile(storedProfile: StoredUser)
}

class ProfileDataServices{
    
    var delegate: ProfileDataServicesDelegate?
    var context: NSManagedObjectContext?
    
    
    func getProfile(with context: NSManagedObjectContext, user: StoredUser){
        
        let username = user.login!
        let url = URL(string: "https://api.github.com/users/\(username)")!
        
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            
            if let error = error {
                
                print(error.localizedDescription)
                return
            }
            
            if let safeData = data{
                
                self.parseJSON(data: safeData,context: context, user: user)
                
            }
        }.resume()
        
    }
    
    private func parseJSON(data: Data,context: NSManagedObjectContext, user: StoredUser){
        
        let decoder = JSONDecoder()
        
        
        do{
            
            let decodedData = try decoder.decode(Profile.self, from: data)
            
            Profile.storeProfileOffline(profile: decodedData,context: context, user: user){ success in
                
                if success{
                    
                    self.delegate?.didGetProfile(storedProfile: user)
                    
                }
            }
            
            
        }catch{
            print(error.localizedDescription)
            
        }
    }

}
