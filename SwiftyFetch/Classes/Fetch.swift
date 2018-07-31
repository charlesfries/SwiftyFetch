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
        
        guard let baseUrl: String = self.baseUrl else {
            //if !verifyUrl(url) {
                print("Base URL not set. Use setBaseUrl(_ baseUrl: String)")
                return
            //}
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
    
    public func request(url: String, params: [String: Any] = [: ], handler: @escaping (_ success: Bool, _ status: String, _ json: JSON) -> ())
    {
        guard let baseUrl = self.baseUrl, let apiKey = self.apiKey else
        {
            print("Base URL or API key not set.")
            return
        }
        
        var p = "key=\(apiKey)"
        
        for (k, v) in params { p += "&\(k)=\(v)" }
        
        var r = URLRequest(url: URL(string: baseUrl + url)!)
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
