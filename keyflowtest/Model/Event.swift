//
//  Event.swift
//  keyflowtest
//
//  Created by Yana Perekrestova on 25.05.2021.
//

import Foundation

struct Event: Decodable {
    
    private static let eventImageBaseUrl = "https://res.cloudinary.com/keyflow/image/upload/"
    private static let eventImageExtension = ".png"
    
    let name: String
    let venueId: Int
    let startDate: Date
    let endDate: Date
    let images: [String]
    
    enum CodingKeys: String, CodingKey {
        case name
        case venueId
        case startDate = "startTime"
        case endDate = "endTime"
        case images
    }
    
    init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        name = try container.decode(String.self, forKey: .name)
        venueId = try container.decode(Int.self, forKey: .venueId)
        startDate = try container.decode(Date.self, forKey: .startDate)
        endDate = try container.decode(Date.self, forKey: .endDate)
        
        images = try container.decode([String].self, forKey: .images)
            .filter { !$0.isEmpty }
            .map { Event.eventImageBaseUrl + $0 + Event.eventImageExtension }
    }
}
