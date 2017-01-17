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

let kPort = UInt16(8080)

class FAPLServer {
    fileprivate let server = HTTPServer()
    
    //MARK: - Lifecycle
    
    init() {
        server.documentRoot = "./webroot"
        
        server.serverPort = kPort
        
        setupRoutes(for: self.server)
        
        do {
            try server.start()
        } catch PerfectError.networkError(let err, let msg) {
            print("Network error thrown: \(err) \(msg)")
        } catch {
            print("Unknown error!")
        }
    }
    
    //MARK: - Routes
    
    fileprivate func setupRoutes(for server: HTTPServer) {
        var routes = Routes()

        setupRouteIndex(&routes)
        
        server.addRoutes(routes)
    }
    
    fileprivate func setupRouteIndex(_  routes: inout Routes) {
        routes.add(method: .get, uris: ["/", "/index.html"]) {
            request, response in
            
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
}
