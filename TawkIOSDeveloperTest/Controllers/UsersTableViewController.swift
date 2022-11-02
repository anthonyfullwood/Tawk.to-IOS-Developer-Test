//
//  UsersTableViewController.swift
//  TawkIOSDeveloperTest
//
//  Created by Anthony Fullwood on 17/10/2022.
//

import Foundation
import UIKit
import CoreData



protocol UserViewModelCell {
    var cellType: UserViewModelCellType{get set}
}

class UsersTableViewController: UITableViewController, UserViewModelCell{
    
    var cellType: UserViewModelCellType = .normal
    private var usersDataServices = UsersDataServices()
    private var userVM = UserViewModel()
    private var profileVM = ProfileViewModel()
    private let mainContext = (UIApplication.shared.delegate as!AppDelegate).mainPersistentContainer.viewContext
    private let backgroundContext = (UIApplication.shared.delegate as!AppDelegate).backgroundPersistentContainer.viewContext
    
    private var networkServices = NetworkServices()
    private var internetConnected = false
    var selectedUser: StoredUser?
    var selectedUserImage: UIImage?
    
    
    private var isPaginating = false
    
    @IBOutlet weak var usersSearchBar: UISearchBar!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return userVM.numberOfSections()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userVM.numberOfRowInSection()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        cellType = userVM.cellForRowAt(indexPath.row)
        
        //Determines the cell that is to be used
        switch cellType {
            
        case .normal:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: CellNibs.normalCell, for: indexPath) as! NormalTableViewCell
            
            
            if let users = userVM.users{
                
                let imageData = UsersDataServices.cache.object(forKey: users[indexPath.row].avatar_url! as NSString ) as Data?
                
                cell.configureCell(users[indexPath.row].login!, users[indexPath.row].type!,imageData)
            }
            
            return cell
            
        case .inverted:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: CellNibs.invertedCell, for: indexPath) as! InvertedTableViewCell
            
            if let users = userVM.users{
                
                let imageData = UsersDataServices.cache.object(forKey: users[indexPath.row].avatar_url! as NSString ) as Data?
                
                cell.configureCell(users[indexPath.row].login!, users[indexPath.row].type!,imageData: imageData)
                
                
                cell.invertImage(imageData)
                
            }
            
            return cell
            
        case .indicator:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: CellNibs.indicatorCell, for: indexPath) as! IndicatorTableViewCell
            
            if let users = userVM.users{
                
                let imageData = UsersDataServices.cache.object(forKey: users[indexPath.row].avatar_url! as NSString ) as Data?
                
                cell.configureCell(users[indexPath.row].login!, users[indexPath.row].type!,imageData)
            }
            
            return cell
        }
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        let selectedCellType = userVM.cellForRowAt(indexPath.row)
        
        //stores the data of the selected user that will be passed to the ProfileViewController
        switch selectedCellType{
            
        case .normal:
            
            let cell = tableView.cellForRow(at: indexPath) as! NormalTableViewCell
            selectedUserImage = nil
            selectedUserImage = cell.userImageView.image
            
        case .indicator:
            
            guard let cell = tableView.cellForRow(at: indexPath) as? IndicatorTableViewCell else{
                fatalError("TableView did not reload")
            }
            selectedUserImage = nil
            selectedUserImage = cell.userImageView.image
            
        case.inverted:
            
            let cell = tableView.cellForRow(at: indexPath) as! InvertedTableViewCell
            
            selectedUserImage = nil
            
            if let image = UIImage(data: cell.imageData!){
                selectedUserImage = image
            }
            
        }
        
        
        
        selectedUser = nil
        selectedUser = userVM.users![indexPath.row]
        
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: SegueIdentifier.goToProfile, sender: self)
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let destinationVC = segue.destination as! ProfileViewController
        
        destinationVC.user = selectedUser
        destinationVC.userImage = selectedUserImage
        destinationVC.profileVM = self.profileVM
        
        
    }
    
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        self.isPaginating = false
        
    }
    
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        let position = scrollView.contentOffset.y + scrollView.frame.size.height
        
        if position >= tableView.contentSize.height && !self.isPaginating{
            
            self.isPaginating = true
            
            let activityIndicator = UIActivityIndicatorView(style: .medium)
            activityIndicator.color =  UIColor.systemTeal
            
            activityIndicator.startAnimating()
            
            activityIndicator.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 44)
            
            self.tableView.tableFooterView = activityIndicator
            self.tableView.tableFooterView?.isHidden = false
            
            if let safeLastUserId = self.userVM.users?.last?.id{
                
                self.usersDataServices.since = safeLastUserId
                
                self.usersDataServices.getUsers(with: self.backgroundContext, pagination: self.isPaginating, isAutoReconnecting: false)
                
            }
            
        }
    }
    
    
    private func setup(){
        
        usersDataServices.delegate = self
        networkServices.delegate = self
        profileVM.delegate = self
        usersSearchBar.delegate = self
        
        
        self.usersDataServices.getStoredUsers(with: self.mainContext)
        self.networkServices.startMonitoring()
        
        
        tableView.register(UINib(nibName: CellNibs.normalCell, bundle: nil), forCellReuseIdentifier: CellNibs.normalCell)
        tableView.register(UINib(nibName: CellNibs.indicatorCell, bundle: nil), forCellReuseIdentifier: CellNibs.indicatorCell)
        tableView.register(UINib(nibName: CellNibs.invertedCell, bundle: nil), forCellReuseIdentifier: CellNibs.invertedCell)
    }
    
    
    
    
}

//MARK: - NetworkServcesDelegate Methods
extension UsersTableViewController : NetworkServicesDelegate{
    func didUpdateNetwork(connected: Bool) {
        
        if connected{
            
            if !internetConnected{
                
                internetConnected = true
                
                DispatchQueue.main.async {
                    self.title = ""
                    self.navigationController?.navigationBar.setNeedsLayout()
                }
                
                self.usersDataServices.getUsers(with: self.backgroundContext,pagination: false, isAutoReconnecting: true)
                
            }
            
            
        }else{
            
            internetConnected = false
            
            DispatchQueue.main.async {
                self.title = "No internet"
                self.navigationController?.navigationBar.setNeedsLayout()
            }
            
        }
        
    }
}

//MARK: - UserDataServicesDelegate Methods
extension UsersTableViewController: UsersDataServicesDelegate{
    
    
    func didGetUsers(users: [StoredUser]) {
    
        userVM.users = users
        
        reloadData()
        
    }
    
    func didGetMoreUser(users: [StoredUser]) {
        
        userVM.users?.append(contentsOf: users)
        
        DispatchQueue.main.async {
            
            self.tableView.tableFooterView?.isHidden = true
            self.tableView.tableFooterView = nil
        }
        reloadData()
        
    }
    
    private func reloadData(){
        DispatchQueue.main.async {
            self.tableView.reloadData()
            
        }
    }
    
}

//MARK: - UISearchBarDelegate Methods
extension UsersTableViewController: UISearchBarDelegate{
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        let searchBarText = searchBar.searchTextField.text!.lowercased()
        
        if searchBarText.isEmpty{
            usersDataServices.getStoredUsers(with: mainContext)
            
        }else{
            userVM.startSearch(searchBarText, mainContext)
        }
        
        searchBar.resignFirstResponder()
        
        reloadData()
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText.isEmpty{
            
            usersDataServices.getStoredUsers(with: mainContext)
            searchBar.resignFirstResponder()
            
        }else{
            
            userVM.startSearch(searchText.lowercased(), mainContext)
            
        }
        
        reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        usersDataServices.getStoredUsers(with: mainContext)
        searchBar.endEditing(true)
        reloadData()
    }
    
    
}

//MARK: - ProfileViewModelDelegate Methods
extension UsersTableViewController: ProfileViewModelDelegate{
    func didUpdateNotes() {
        
        self.tableView.reloadData()
        
    }
}


