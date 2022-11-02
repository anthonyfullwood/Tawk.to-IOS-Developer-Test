//
//  NormalTableViewCell.swift
//  TawkIOSDeveloperTest
//
//  Created by Anthony Fullwood on 18/10/2022.
//

import UIKit

class NormalTableViewCell: UITableViewCell {

    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var detailsLabel: UILabel!
    @IBOutlet weak var userView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupViews()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    private func setupViews(){
        
        userView.layer.cornerRadius = 10
        
        userImageView.layer.borderWidth = 1
        userImageView.layer.masksToBounds = false
        userImageView.layer.borderColor = UIColor.systemTeal.cgColor
        userImageView.layer.cornerRadius = userImageView.frame.height / 2
        userImageView.clipsToBounds = true
        
    }
    
    func configureCell(_ username: String,_ details: String,_ imageData: Data?){
        
        
        usernameLabel.text = username
        detailsLabel.text = details
        
        if let safeImageData = imageData{
            userImageView.image = UIImage(data: safeImageData)
        }
        
       
    }
    
}
