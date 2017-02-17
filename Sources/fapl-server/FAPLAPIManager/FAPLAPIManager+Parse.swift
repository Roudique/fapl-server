//
//  FAPLAPIManager+Parse.swift
//  fapl-server
//
//  Created by Roudique on 1/18/17.
//
//

import Foundation
import Scrape

extension FAPLAPIManager {
    
    func parsePost(with html: String) -> FAPLPost? {
        if let doc = HTMLDocument(html: html, encoding: .windowsCP1251) {
            var post = FAPLPost()
            
            guard let content = doc.element(atXPath: "//div[@class='content']", namespaces: nil) else {return nil}
            
            //parse title
            post.title = parseName(content: content)
            
            //parse paragraphs
            let contentNodes = Array.init(content.search(byXPath: "p").enumerated())
            var paragraphs = [String]()
            for node in contentNodes {
                
                if node.offset == 0 {
                    let imgPath = parseImage(element: node.element)
                    post.imgPath = imgPath
                }
                
                if let paragraph = node.element.content {
                    paragraphs.append(contentsOf: paragraph.components(separatedBy: .newlines).filter({ p in
                        return !p.isEmpty
                    }))
                }
            
            }
            post.paragraphs = paragraphs
            
            //parse tags
            let tags = parseTags(doc: doc)
            post.tags = tags
            
            //parse timestamp
            let dateXPath = doc.search(byXPath: "//p[@class='date f-r']")
            switch dateXPath {
            case .nodeSet(let dateNodeSet):
                if let dateTimeString = dateNodeSet.first?.content {
                    if let date = parse(date: dateTimeString) {
                        post.timestamp = Int(date.timeIntervalSince1970)
                    }
                }
            default:
                break
            }
            
            return post
        }
        
        return nil
    }
    
    private func parseName(content: XPathResult._Element) -> String? {
        let block = content.element(atXPath: "//div[@class='block']")
        let h2 = block?.element(atCSSSelector: "h2")
        return h2?.content
    }
    
    private func parseTags(doc: HTMLDocument) -> [String] {
        guard let tagsContent = doc.element(atXPath: "//p[@class='tags']", namespaces: nil)?.content else {return []}
        let tags = tagsContent.components(separatedBy: ",").map({ tag in
            return tag.trimmingCharacters(in: .whitespacesAndNewlines)
        })
        return tags
    }
    
    private func parseImage(element: XPathResult._Element) -> String? {
        if let imgNode = element.search(byXPath: "img").first {
            if let imgPath = imgNode["src"] {
                return imgPath
            }
        }
        
        return nil
    }
    
    private func parse(date: String) -> Date? {
        let components = date.components(separatedBy: " ").filter { str in
            !str.isEmpty
        }
        let comp = (components.first, components.last)
        if let dateString = comp.0, let timeString = comp.1 {
            let fullDateString = "\(dateString) \(timeString)"
            
            let moscowGMTTimeDifference = 60 * 60 * 3
            let dateFormatter = DateFormatter()
            dateFormatter.timeZone = TimeZone.init(secondsFromGMT: moscowGMTTimeDifference)
            dateFormatter.dateFormat = "dd.MM.yyyy hh:mm"
            
            return dateFormatter.date(from: fullDateString)
        }
        
        return nil
    }
    
}
