//
//  ViewController.swift
//  BreweriesApp
//
//  Created by viki benhaim on 15/09/2022.
//

import UIKit
import CoreLocation

class BreweriesListViewController: UIViewController {
  
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var filterByFavoriteButton: UIButton!
    @IBOutlet weak var favoriteListEmptyLabel: UILabel!
    
    @IBOutlet weak var sortByNearMeButton: UIButton!
    @IBOutlet weak var sortByNearMeLabel: UILabel!
    @IBOutlet weak var sortByNearMeIcon: UIImageView!
    @IBOutlet weak var sortByNearMeView: UIView!
    
    var locationManager = CLLocationManager()
    var myLocation : CLLocation?
    
    var service = BreweryService()
    
    var breweriesList : [Brewery]? {
        didSet {
            if isViewLoaded {
                tableView.reloadData()
                tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
                loadingIndicator.stopAnimating()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        reloadSortByNearMeButtonDesign()
        
        loadBreweriesDataFromApi()
    }
    
    // load data from api: regular list or sorted by my location
    func loadBreweriesDataFromApi() {
        loadingIndicator.startAnimating()
        
        if sortByNearMeButton.isSelected {
            service.loadBreweriesListByDistance(nil, lat: myLocation?.coordinate.latitude, lng: myLocation?.coordinate.longitude) { [weak self] (breweries, isSuccess) in
                guard let self = self else { return }
                
                if isSuccess == true {
                    self.breweriesList = breweries
                }
            }
        } else {
            service.loadBreweriesList(nil, completionHandler: { [weak self] (breweries, isSuccess) in
                guard let self = self else { return }
                
                if isSuccess == true {
                    self.breweriesList = breweries
                }
            })
        }
    }
    
    @IBAction func filterByFavoriteClicked(_ sender: Any) {
        filterByFavoriteButton.isSelected = !filterByFavoriteButton.isSelected
        
        sortByNearMeButton.isSelected = false
        reloadSortByNearMeButtonDesign()
        
        if filterByFavoriteButton.isSelected {
            tableView.reloadData()
        } else {
            loadBreweriesDataFromApi()
        }
    }
    
    @IBAction func sortByNearMeClicked(_ sender: Any) {
        sortByNearMeButton.isSelected = !sortByNearMeButton.isSelected
        
        filterByFavoriteButton.isSelected = false
        
        if sortByNearMeButton.isSelected {
            locationManager.requestWhenInUseAuthorization()
            if CLLocationManager.locationServicesEnabled() {
                locationManager.delegate = self
                locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
                locationManager.startUpdatingLocation()
            }
        } else {
            loadBreweriesDataFromApi()
        }
        
        reloadSortByNearMeButtonDesign()
    }
    
    func reloadSortByNearMeButtonDesign() {
        sortByNearMeView.layer.cornerRadius = 8
        sortByNearMeView.layer.masksToBounds = true
        
        if sortByNearMeButton.isSelected {
            sortByNearMeIcon.image = UIImage(named: "near_me_icon_on")
            sortByNearMeView.backgroundColor = UIColor(red: 103/255, green: 137/255, blue: 174/255, alpha: 1.0)
            sortByNearMeLabel.textColor = .white
        } else {
            sortByNearMeIcon.image = UIImage(named: "near_me_icon_off")
            sortByNearMeView.backgroundColor = .white
            sortByNearMeLabel.textColor = UIColor(red: 103/255, green: 137/255, blue: 174/255, alpha: 1.0)
            
        }
    }
}


//
// MARK: - Table View Data Source
//
extension BreweriesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        favoriteListEmptyLabel.text = ""
        if filterByFavoriteButton.isSelected {
            if service.favoriteBreweriesList.count == 0 {
                favoriteListEmptyLabel.text = "Favorites list is empty"
            }
            return service.favoriteBreweriesList.count
        }
        return breweriesList?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BreweryCell") as! BreweryTableViewCell
        
        let breweryItem:Brewery
        if filterByFavoriteButton.isSelected {
            breweryItem = service.favoriteBreweriesList[indexPath.row]
        } else {
            breweryItem = breweriesList![indexPath.row]
        }
        
        cell.delegate = self
        cell.breweryItem = breweryItem
        cell.nameLabel.text = breweryItem.name ?? "-"
        cell.phoneLabel.text = breweryItem.phone ?? "-"
        cell.addressLabel.text = "\(breweryItem.street ?? ""), \(breweryItem.city ?? ""), \(breweryItem.state ?? "")"
        
        cell.favoriteButton.isSelected = service.favoriteBreweriesList.contains(where: { $0.id == breweryItem.id })
        
        if let latitude = breweryItem.latitude, let longitude = breweryItem.longitude {
            cell.locationAddress = CLLocation(latitude: Double(latitude)!, longitude: Double(longitude)!)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 155
    }
}

//
// MARK: - Table View Delegate
//
extension BreweriesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
}


//
// MARK: - CLLocation Manager Delegate
//
extension BreweriesListViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        print("locations = \(locValue.latitude) \(locValue.longitude)")
        
        myLocation = manager.location
        
        // Stop updating location
        locationManager.stopUpdatingLocation()
        locationManager.delegate = nil
        
        loadBreweriesDataFromApi()
        
    }
}

//
// MARK: - BreweryTableViewCell Delegate
//
extension BreweriesListViewController : BreweryTableViewCellDelegate {
    func favoriteBreweriesSelectionChange(_ isFavorite: Bool, breweryItem: Brewery?) {
        guard let breweryItem = breweryItem else {
            return
        }
        
        // Change favorite selection list
        if isFavorite {
            service.addItemToFavoriteList(breweryItem)
        } else {
            service.removeItemFromFavoriteList(breweryItem)
        }
        
        // Reload the tableview only for favorite filter
        if filterByFavoriteButton.isSelected {
            tableView.reloadData()
        }
    }
}
