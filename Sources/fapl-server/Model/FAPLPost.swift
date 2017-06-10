//
//  FAPLPost.swift
//  fapl-server
//
//  Created by Roudique on 1/18/17.
//
//

import Foundation
//import SwiftyJSON


let kID         = "id"
let kTitle      = "title"
let kText       = "text"
let kParagraphs = "paragraphs"
let kImageShort = "img"
let kTags       = "tags"
let kTimestamp  = "timestamp"


struct FAPLPost  {
    var id : Int?
    var exists: Bool = false
    
    var imgPath     : String?
    var title       : String?
    
    var timestamp   : Int?
    
    var paragraphs  = [String]()
    var tags        = [String]()
}
