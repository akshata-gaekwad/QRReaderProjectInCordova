//
//  Servermanager.swift
//  ARKitNavigationDemo
//
//  Created by indianrenters on 18/04/19.
//  Copyright © 2019 Christopher Webb-Orenstein. All rights reserved.
//

import Foundation



public enum Api{

//  static let AccountOverview = "http:/14.141.164.230:9022/MobilityMiddleWare/middleware"
    static let AccountOverview = "http:/14.141.164.230:9022/MobilityMiddleWare/middleware"

}


public class Servermanager {

    public static let sharedManager = Servermanager()

    func getData(apiUrl:String,parameters:[String:Any] , completion: @escaping (Bool , [String:Any]?) -> Void) {

        let Url = String(format: Api.AccountOverview)
        
        guard let serviceUrl = URL(string: Url) else { return }
        
        let parameterDictionary = parameters
        
        var request = URLRequest(url: serviceUrl)
        
        request.httpMethod = "POST"
        
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameterDictionary, options: []) else {
            return
        }

        request.httpBody = httpBody
        
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 30.0
        sessionConfig.timeoutIntervalForResource = 60.0
        let session = URLSession(configuration: sessionConfig)
       
        session.dataTask(with: request) { (data, response, error) in
            if let response = response {
                print(response)
            }
            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    completion(true , (json as? [String:Any]))
                } catch {
                    completion(false , nil)
                }
            }
            }.resume()
    }
  
}


