import PerfectHTTP
import PerfectHTTPServer
import PerfectLib
import PerfectMustache

let server = HTTPServer()
server.documentRoot = "./webroot"

var routes = Routes()

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

server.addRoutes(routes)

server.serverPort = 8080

do {
    try server.start()
} catch PerfectError.networkError(let err, let msg) {
    print("Network error thrown: \(err) \(msg)")
}
