//
//  BreweryService.swift
//  BreweriesApp
//
//  Created by viki benhaim on 15/09/2022.
//

import Foundation

class BreweryService {
    
    let basePath = "https://api.openbrewerydb.org/breweries"
    
    var favoriteBreweriesList: [Brewery] {
        didSet {
            // Save the favorites list in UserDefaults
            UserDefaults.standard.set(try? PropertyListEncoder().encode(favoriteBreweriesList), forKey: "favoriteBreweriesList")
        }
    }
    
    
    init() {
        // load favorites list from UserDefaults
        let favoriteData = UserDefaults.standard.data(forKey: "favoriteBreweriesList") ?? Data()
        favoriteBreweriesList = (try? PropertyListDecoder().decode([Brewery].self, from: favoriteData)) ?? []
    }
    
    func addItemToFavoriteList(_ item: Brewery) {
        favoriteBreweriesList.append(item)
    }
    
    func removeItemFromFavoriteList(_ item: Brewery) {
        favoriteBreweriesList.removeAll{ $0.id == item.id }
    }
    
    
    //
    // MARK: - Api Requests
    //
    
    func loadBreweriesList(_ url: String?, completionHandler: @escaping ([Brewery]?, Bool?) -> Void) {
        
        let urlString = url ?? basePath
        
        NetworkService.loadData(url: urlString, type: [Brewery].self) { (listBreweries, error) in
            guard error == nil else {
                completionHandler(nil, false)
                return
            }
            
            completionHandler(listBreweries, true)
        }
    }
    
    func loadBreweriesListByDistance(_ url: String?, lat:Double?, lng: Double?, completionHandler: @escaping ([Brewery]?, Bool?) -> Void) {
        
        guard let lat = lat, let lng = lng else {
            return
        }
        
        let urlString = "\(url ?? basePath)?by_dist=\(lat),\(lng)"
        
        NetworkService.loadData(url: urlString, type: [Brewery].self) { (listBreweries, error) in
            guard error == nil else {
                completionHandler(nil, false)
                return
            }
            
            completionHandler(listBreweries, true)
        }
    }
}
