//
//  FAPLServer.swift
//  fapl-server
//
//  Created by Roudique on 1/16/17.
//
//

import PerfectHTTP
import PerfectHTTPServer
import PerfectLib
import PerfectMustache
import Foundation
import SwiftyJSON

let kPort = UInt16(8181)

class FAPLServer  {
    fileprivate let server = HTTPServer()
    
    
    //MARK: - Lifecycle
    
    func run() {
        server.documentRoot = "./webroot"
        
        server.serverPort = kPort
        
        setupRoutes(for: self.server)
        
        do {
            try server.start()
        } catch PerfectError.networkError(let err, let msg) {
            print("Network error thrown: \(err) \(msg)")
        } catch PerfectError.apiError(let err) {
            print("API error thrown: \(err)")
        } catch PerfectError.fileError(let err, let msg) {
            print("File error thrown: \(err) \(msg)")
        } catch PerfectError.systemError(let err, let msg) {
            print("System error thrown: \(err) \(msg)")
        } catch {
            print("Not PerfetError thrown :(")
        }
    }

    
    //MARK: - Routes
    
    fileprivate func setupRoutes(for server: HTTPServer) {
        var apiV1Routes = Routes()

        setupRouteIndex(&apiV1Routes)
        setupRouteFaplPost(&apiV1Routes)
        
        server.addRoutes(apiV1Routes)
    }
    
    fileprivate func setupRouteIndex(_  routes: inout Routes) {
        routes.add(method: .get, uris: ["/", "/index.html"]) {
            request, response in
            
            print(request.params())
                        
            response.setHeader(.contentType, value: "text/html")
            
            mustacheRequest(
                request: request,
                response: response,
                handler: Handler(),
                templatePath: request.documentRoot + "/index.mustache"
            )
            
            response.completed()
        }
    }
    
    fileprivate func setupRouteFaplPost(_ routes: inout Routes) {
        routes.add(method: .get, uri: "/post/{id}") { request, response in
            response.setHeader(.contentType, value: "application/json")

            //TODO: finish
            
            
            
            response.completed()
        }
    }
}
