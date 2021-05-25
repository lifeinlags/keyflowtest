//
//  CombinedEvent.swift
//  keyflowtest
//
//  Created by Yana Perekrestova on 25.05.2021.
//

import Foundation

struct CombinedEvent {
    
    let event: Event
    let venue: Venue
    
    init(event: Event, venue: Venue) {
        self.event = event
        self.venue = venue
    }
}
