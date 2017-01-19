//
//  FAPLAPIManager.swift
//  fapl-server
//
//  Created by Roudique on 1/16/17.
//
//

import Foundation
import PerfectHTTP

class FAPLAPIManager {
    let defaultSession = URLSession(configuration: .default)
    var dataTask: URLSessionDataTask?
    
    fileprivate let kEncoding       = String.Encoding.windowsCP1251
    fileprivate let kBaseFAPLUrl    = "http://fapl.ru"
    fileprivate let kPosts          = "/posts"
    
    //MARK: - Public
    
    func requestPost(with id: Int, completionHandler: @escaping (String?, FAPLError?) -> Void) {
        if dataTask != nil {
            dataTask?.cancel()
        }
        
        let url = NSURL(string: kBaseFAPLUrl + kPosts + "/\(id)")

        dataTask = defaultSession.dataTask(with: url! as URL) {
            data, response, error in
            
            if let error = error {
                print("Error during fetching post! Description: " + error.localizedDescription)
                completionHandler(nil, FAPLError.unknown(-1, error.localizedDescription))
                
            } else if let httpResponse = response as? HTTPURLResponse {
                
                if httpResponse.statusCode == HTTPResponseStatus.ok.code, let data = data {
                    if let str = String.init(data: data, encoding: self.kEncoding){
                        
                        self.parsePost(with: str)
                        completionHandler(str, nil)
                    }
                }
            } else {
                completionHandler(nil, FAPLError.unknown(-1, "unknown error"))
            }
        }
        
        dataTask?.resume()
    }
}

