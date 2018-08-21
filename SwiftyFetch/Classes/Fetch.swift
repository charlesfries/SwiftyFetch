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
                        handler: @escaping (_ error: Error?, _ response: JSON) -> ()) {
        
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
            print("Invalid HTTP method. Method must be POST, GET, PUT, PATCH, or DELETE")
            return
        }
        
        // compiling body string from dict
        var bodyArr: [String] = []
        for (k, v) in body { bodyArr += ["\(k)=\(v)"] }
        let bodyStr = bodyArr.joined(separator: "&")
        
        // request instantiation
        let fullUrl = baseUrl + url
        var r = URLRequest(url: URL(string: fullUrl)!)
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
            
            var payload: JSON = []
            
            if error == nil {
                let http = response as! HTTPURLResponse
                
                let status = http.statusCode
                let isOk = http.statusCode == 200
                let statusText = isOk ? "ok" : HTTPURLResponse.localizedString(forStatusCode: status)
                let headers = http.allHeaderFields
                
                payload = [
                    "status": status,
                    "statusText": statusText,
                    "ok": isOk,
                    "headers": headers,
                    "url": fullUrl,
                    "text": "",
                    "json": [:]
                ]
                
                do {
                    let jsonData = try JSON(data: data!)
                    
                    payload["text"] = jsonData
                    payload["json"] = jsonData
                } catch {
                    payload["ok"] = false
                    payload["text"] = ""
                    payload["json"] = [:]
                }
            }
            
            DispatchQueue.main.async { handler(error, payload) }
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
