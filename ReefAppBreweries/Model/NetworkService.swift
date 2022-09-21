//
//  Network.swift
//  FidoNews
//
//  Created by viki benhaim on 28/08/2022.
//

import Foundation

class NetworkService {
    static func loadData<T: Decodable>(url urlStr: String,
                                       type: T.Type,
                                       queue: DispatchQueue? = DispatchQueue.main,
                                       simulateLoadDelay: Bool? = true,
                                       delaySeconds: TimeInterval = 0.2,
                                       completionHandler: @escaping (T?, NetworkError?) -> Void) {
        
        guard let url = URL(string: urlStr) else {
            completionHandler(nil, .invalidUrl)
            
            return
        }
        
        let request = URLRequest(url: url)
        
        let dataTask = URLSession.shared.dataTask(with: request) { (data, response, error) in
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 200
            
            if statusCode != 200 {
                if let dispatchQueue = queue {
                    dispatchQueue.asyncAfter(deadline: DispatchTime.now() + delaySeconds) {
                        completionHandler(nil, .requestError)
                    }
                } else {
                    completionHandler(nil, .requestError)
                }
                
                return
            }
            
            do {
                if let jsonData = data {
                    let decoder = JSONDecoder()
                    
                    let typedObject: T? = try decoder.decode(T.self, from: jsonData)
                    
                    if let dispatchQueue = queue {
                        dispatchQueue.asyncAfter(deadline: DispatchTime.now() + delaySeconds) {
                            completionHandler(typedObject, nil)
                        }
                    } else {
                        completionHandler(typedObject, nil)
                    }
                }
            } catch {
                print(error)
                
                if let dispatchQueue = queue {
                    dispatchQueue.asyncAfter(deadline: DispatchTime.now() + delaySeconds) {
                        completionHandler(nil, .parseError)
                    }
                } else {
                    completionHandler(nil, .parseError)
                }
            }
        }
        
        dataTask.resume()
    }
}
