//
//  BreweryTableViewCell.swift
//  BreweriesApp
//
//  Created by viki benhaim on 18/09/2022.
//

import UIKit
import CoreLocation

protocol BreweryTableViewCellDelegate: AnyObject {
    func favoriteBreweriesSelectionChange(_ isFavorite: Bool, breweryItem:Brewery?)
}

class BreweryTableViewCell: UITableViewCell {
    
    weak var delegate: BreweryTableViewCellDelegate?
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
    
    var locationAddress: CLLocation?
    
    var breweryItem: Brewery?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    @IBAction func addToFavoriteListClicked(_ sender: UIButton) {
        favoriteButton.isSelected = !favoriteButton.isSelected
        delegate?.favoriteBreweriesSelectionChange(favoriteButton.isSelected, breweryItem: breweryItem)
    }
    
    @IBAction func phoneClicked(_ sender: UIButton) {
        // Check if the phone number is valid and open phone call
        if let phoneNumber = phoneLabel.text {
            guard let number = URL(string: "tel://" + phoneNumber) else { return }
            UIApplication.shared.open(number)
        }
    }
    
    @IBAction func addressClicked(_ sender: UIButton) {
        // Check if the location coordinates are valid and open navigation application to this address
        if let latitude = locationAddress?.coordinate.latitude, let longitude = locationAddress?.coordinate.longitude {
            if let locationUrl = URL(string: String(format:"http://maps.apple.com/?daddr=%f,%f&dirflg=d", latitude, longitude)) {
                UIApplication.shared.open(locationUrl, options: [:], completionHandler: nil)
            }
        }
    }
}
