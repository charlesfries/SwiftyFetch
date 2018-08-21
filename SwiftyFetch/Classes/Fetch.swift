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
    private init() {}
    
    private var baseUrl: String!
    private var apiKey: String!
    private var token: String!
    
    public func setBaseUrl(_ baseUrl: String) { self.baseUrl = baseUrl }
    public func setAPIKey(_ apiKey: String) { self.apiKey = apiKey }
    public func setToken(_ token: String) { self.token = token }
    
    public func request(_ url: String,
                        method: String,
                        headers: [String: String] = [:],
                        body: [String: Any] = [:],
                        handler: @escaping (_ response: JSON) -> ()) {
        
        if baseUrl == nil {
            if !verifyUrl(url) {
                print("Could not derive full URL from parameter")
            }
            print("Base URL not set. Use setBaseUrl(_ baseUrl: String)")
            return
        }
        
        let httpMethod: String
        switch method.uppercased() {
        case "POST":
            httpMethod = "POST"
        case "GET":
            httpMethod = "GET"
        case "PUT":
            httpMethod = "PUT"
        case "PATCH":
            httpMethod = "PATCH"
        case "DELETE":
            httpMethod = "DELETE"
        default:
            print("Invalid HTTP method.")
            return
        }
        
        // compiling body string from dict
        var bodyArr: [String] = []
        for (k, v) in body { bodyArr += ["\(k)=\(v)"] }
        let bodyStr = bodyArr.joined(separator: "&")
        
        // request instantiation
        var r = URLRequest(url: URL(string: baseUrl + url)!)
        r.httpMethod = httpMethod
        r.httpBody = bodyStr.data(using: String.Encoding.utf8)
        
        // appending headers
        for (k, v) in headers { r.addValue(v, forHTTPHeaderField: k) }
        
        // adding authorization headers
        var authArr: [String] = []
        if apiKey != nil { authArr += ["Apikey \(apiKey)"] }
        if token != nil { authArr += ["Bearer \(token)"] }
        r.addValue(authArr.joined(separator: ","), forHTTPHeaderField: "Authorization")
        
        let t = URLSession.shared.dataTask(with: r) {
            data, response, error in
            
            var res: JSON = [
                "status": 401,
                "statusText": "Unauthorized",
                "ok": false,
                "headers": [:],
                "url": "https://",
                "text": "",
                "json": [:]
            ]
            
            if error != nil {
                res["ok"] = false
                res["text"] = ""
                res["json"] = [:]
            } else {
                do {
                    let jsonData = try JSON(data: data!)
                    
                    res["ok"] = true
                    res["text"] = jsonData
                    res["json"] = jsonData
                } catch {
                    res["ok"] = false
                    res["text"] = ""
                    res["json"] = [:]
                }
            }
            
            DispatchQueue.main.async { handler(res) }
        }
        t.resume()
    }
    
    private func verifyUrl(_ urlString: String?) -> Bool {
        if let urlString = urlString {
            if let url = URL(string: urlString) {
                return UIApplication.shared.canOpenURL(url)
            }
        }
        return false
    }
}
