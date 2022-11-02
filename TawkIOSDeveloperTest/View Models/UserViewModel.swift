//
//  UserViewModel.swift
//  TawkIOSDeveloperTest
//
//  Created by Anthony Fullwood on 17/10/2022.
//

import Foundation
import UIKit
import CoreData


enum UserViewModelCellType {
    case normal
    case inverted
    case indicator
    
}

class UserViewModel{
    
    var users: [StoredUser]?
    
    func numberOfSections() -> Int{
        return 1
    }
    
    func numberOfRowInSection() -> Int{
        
        if let users = users {
            return users.count
        }
        
        return 0
        
    }
    
    //Determines the cell type for each row
    func cellForRowAt(_ index: Int) -> UserViewModelCellType {
        
        
        let cellNumber = index + 1 - 4
       
        
        if users![index].notes != nil{
            
            return .indicator
           
        }
        
        if cellNumber == 0 || cellNumber % 4 == 0{
           
            return .inverted
           
        }else{
            
            return .normal
          
        }
        
        
            
            
    }
    
    func startSearch(_ searchText: String,_ context: NSManagedObjectContext){
        
        
        let request: NSFetchRequest<StoredUser> = StoredUser.fetchRequest()
        
        let predicateFormat1 = "login CONTAINS %@ OR login MATCHES %@"
        let predicate1 = NSPredicate(format: predicateFormat1, searchText,searchText)
        
        let predicateFormat2 = "notes CONTAINS %@ OR notes MATCHES %@"
        let predicate2 = NSPredicate(format: predicateFormat2, searchText,searchText)
        
        request.predicate = NSCompoundPredicate(orPredicateWithSubpredicates: [predicate1,predicate2])
        
        do{
            users = try context.fetch(request)
          
        }catch{
            print("Error fetching data \(error.localizedDescription)")
        }
    }

    
}




