//
//  ProfileViewController.swift
//  TawkIOSDeveloperTest
//
//  Created by Anthony Fullwood on 24/10/2022.
//

import Foundation
import UIKit
import SwiftUI
import CoreData

class ProfileViewController: UIViewController{
    
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var user : StoredUser?
    var userImage: UIImage?
    var profileVM : ProfileViewModel?
    private let context = (UIApplication.shared.delegate as!AppDelegate).backgroundPersistentContainer.viewContext
    private var profileDataServices = ProfileDataServices()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    
    func setup(){
        
        profileDataServices.delegate = self
        
        if let safeUser = user {
            
            DispatchQueue.global().async {
                self.profileDataServices.getProfile(with: self.context, user: safeUser)
            }
            
        }
        
    }
    
}

//MARK: - ProfileDataServicesDelegate Methods
extension ProfileViewController: ProfileDataServicesDelegate{
    
    func didGetProfile(storedProfile: StoredUser) {
        
        if let profileVM = self.profileVM{
            profileVM.profileData = storedProfile
            profileVM.userImage = self.userImage
            profileVM.context = self.context
        }
        
        DispatchQueue.main.async {
            
            self.title = storedProfile.profile?.name
            
            //Adds swiftui view to ProfileViewController Storyboard
            let childView = UIHostingController(rootView: ProfileSwiftUIView(profileVM: self.profileVM!, notes: (self.profileVM?.getNotes())!))
            self.addChild(childView)
            childView.view.frame = self.container.bounds
            self.activityIndicator.stopAnimating()
            self.container.addSubview(childView.view)
            
        }
    }
}

