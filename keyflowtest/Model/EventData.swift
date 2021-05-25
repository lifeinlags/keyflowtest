//
//  EventData.swift
//  keyflowtest
//
//  Created by Yana Perekrestova on 25.05.2021.
//

import Foundation

struct EventData: Decodable {
    
    let combinedEvents: [CombinedEvent]
    
    // MARK: - Decodable
    
    enum CodingKeys: String, CodingKey {
        case data
        case events
        case venues
    }
    
    init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let data = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .data)
        
        let venues = try data.decode([Venue].self, forKey: .venues)
        let venuesById = venues.reduce(into: [Int: Venue]()) {
            $0[$1.venueId] = $1
        }
        
        let events = try data.decode([Event].self, forKey: .events)
        combinedEvents = events
            .map { ($0, venuesById[$0.venueId]) }
            .compactMap({ (event, venue) in
                guard let venue = venue else { return nil }
                return CombinedEvent(event: event, venue: venue)
            })
    }
}
