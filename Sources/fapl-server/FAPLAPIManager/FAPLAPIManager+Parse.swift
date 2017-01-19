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
    func parse(date: String) -> Date? {
        //        let components = date.split(delimiter: .init(charactersIn: " "), needEmpty: false)
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
        //    }
    }
    
    
    func parsePost(with html: String) -> Void {
        var postName : String?
        
        if let doc = HTMLDocument(html: html, encoding: .utf8) {
            //parse name of post
            let header = doc.search(byXPath: "//h2")
            switch header {
            case .nodeSet(let headers):
                for headerXML in headers {
                    if headerXML.parent?.className == "block" {
                        postName = headerXML.text
                    }
                }
            default:
                break;
            }
            
            var items = [String]()
            var comparisonParagraphs = [String]()
            var logoImage : String?
            
            let content = doc.search(byXPath: "//div[@class='content']")
            
            //parse text of post
            switch content {
            case .nodeSet(let contentSet):
                for content in contentSet {
                    if content.parent?.className == "block" {
                        
                        for offsetAndelement in content.search(byXPath: "p").enumerated() {
                            let element = offsetAndelement.element
                            
                            let images = element.search(byXPath: "img")
                            logoImage = images.first?["src"]
                            if logoImage != nil {
                                print("Logo image: \(logoImage)\n")
                            }
                            
                            if images.count > 1 {
                                for _ in 1...images.count-1 {
                                    //                                    print("Image: \(images.enumerated())")
                                    print("Image detected")
                                }
                            }
                            
                            if let paragraphItem = element.content {
                                let separatedParagraphs = paragraphItem.components(separatedBy: .controlCharacters).filter({ str in
                                    !str.isEmpty
                                })
                                var paragraphs = [String]()
                                for paragraph in separatedParagraphs {
                                    paragraphs.append(paragraph)
                                }
                                
                                items.append(contentsOf: paragraphs)
                            }
                            
                            if let paragraphItem = element.content {
                                
                                let separatedParagraphs = paragraphItem.components(separatedBy: .controlCharacters).filter({ string in
                                    !string.isEmpty
                                })
                                
                                var paragraphs = [String]()
                                for paragraph in separatedParagraphs {
                                    paragraphs.append(paragraph)
                                }
                                
                                comparisonParagraphs.append(contentsOf: paragraphs)
                            }
                        }
                        
                    }
                }
            default:
                break
            }
            
            var tags = [String]()
            let tagsXPath = doc.search(byXPath: "//p[@class='tags']")
            switch tagsXPath {
            case .nodeSet(let tagsSet):
                for tag in tagsSet {
                    if let tagString = tag.content {
                        let tagsArray = tagString.components(separatedBy: CharacterSet.init(charactersIn: ",")).filter({ string in
                            !string.isEmpty
                        })
                        //                        tagsArray = tagsArray.map({ str in
                        //                            return str.trim()
                        //                        })
                        
                        tags.append(contentsOf: tagsArray)
                    }
                }
            default:
                break
            }
            
            let dateXPath = doc.search(byXPath: "//p[@class='date f-r']")
            var timestamp : Int?
            switch dateXPath {
            case .nodeSet(let dateNodeSet):
                if let dateTimeString = dateNodeSet.first?.content {
                    if let date = parse(date: dateTimeString) {
                        timestamp = Int(date.timeIntervalSince1970)
                    }
                }
            default:
                break
            }
            
            if let name = postName {
//                let post = FAPLPost.init(ID: id, imgPath: logoImage, title: name, paragraphs: items)
                var post = FAPLPost()
                post.imgPath = logoImage
                post.title = name
                post.paragraphs = items
                post.tags = tags
                post.timestamp = timestamp
                
                print("Post name: \(name), tags: \(tags)")

                return;
            } else {
                print("Error parsing HTML:\n")
                if postName == nil {
                    print("-- no post name found;")
                }
            }
           
            print(postName ?? "netu posta imeni :(")
            
        }
        
        
        
    }
}
