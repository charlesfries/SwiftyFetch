//
//  Fetch.swift
//  SwiftyFetch
//
//  Created by Charles Fries on 7/31/18.
//  Copyright © 2018 Charles Fries. All rights reserved.
//

import Foundation
import SwiftyJSON

public final class Fetch
{
    public static let shared = Fetch()
    private init() { }
    
    private var baseURL: String!
    private var apiKey: String!
    
    public func setBaseURL(_ baseURL: String) { self.baseURL = baseURL }
    public func setAPIKey(_ apiKey: String) { self.apiKey = apiKey }
    
    public func request(url: String, params: [String: Any] = [: ], handler: @escaping (_ success: Bool, _ status: String, _ json: JSON) -> ())
    {
        guard let b = baseURL, let a = apiKey else
        {
            print("Base URL or API key not set.")
            return
        }
        
        var p = "key=\(a)"
        
        for (k, v) in params { p += "&\(k)=\(v)" }
        
        var r = URLRequest(url: URL(string: b + url)!)
        r.httpMethod = "POST"
        r.httpBody = p.data(using: String.Encoding.utf8)
        
        let t = URLSession.shared.dataTask(with: r)
        {
            data, response, error in
            
            var success: Bool
            var status: String
            var json: JSON
            
            if error != nil
            {
                success = false
                status = "Error connecting to server."
                json = []
            }
            else
            {
                do
                {
                    let jsonData = try JSON(data: data!)
                    
                    success = jsonData["success"].boolValue
                    status = jsonData["status"].stringValue
                    json = jsonData["json"]
                }
                catch
                {
                    success = false
                    status = "An unknown error occurred."
                    json = []
                }
            }
            
            DispatchQueue.main.async { handler(success, status, json) }
        }
        t.resume()
    }
}
