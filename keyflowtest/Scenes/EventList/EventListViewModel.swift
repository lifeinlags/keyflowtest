//
//  EventListViewModel.swift
//  keyflowtest
//
//  Created by Yana Perekrestova on 24.05.2021.
//

import Foundation

protocol EventListViewModelDelegate: AnyObject {
    func loadingDidBegin()
    func loadingDidFinish()
    func viewModelDidUpdate()
}

final class EventListViewModel {
    
    private let url: URL = URL(string: "https://stage-api.keyflow.com/capi/v4/events/")!
    
    var eventData: EventData? = nil
    private var eventsLoadingOperation: URLSessionDataTask? = nil
    
    private weak var delegate: EventListViewModelDelegate?
    
    init(delegate: EventListViewModelDelegate) {
        self.delegate = delegate
    }
    
    func reloadEvents() {
        
        OperationQueue.main.addOperation { [unowned self] in
            
            print("events loading operation did start")
                        
            //checking if loading operation does not exist
            //otherwise do nothing (no need to relaunch the same task)
            guard self.eventsLoadingOperation == nil else { return }
            
            self.delegate?.loadingDidBegin()
            
            //creating URLRequest
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            self.eventsLoadingOperation = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
                
                self?.delegate?.loadingDidFinish()
                
                //check internal error
                guard error == nil else {
                    
                    //engine error occured
                    return
                }
                
                //checking http response
                guard let httpResponse = response as? HTTPURLResponse else {
                    
                    //unexpected url response
                    return
                }
                
                //checking for erroneous http status code
                guard (200...299).contains(httpResponse.statusCode) else {
                    
                    //erroneous http status code
                    return
                }
                
                //check data
                guard let jsonData = data else {
                    
                    //empty data
                    return
                }
                
                //parse events from data as json
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                guard let eventData = try? decoder.decode(EventData.self, from: jsonData) else {
                    
                    //parse error
                    return
                }
                
                OperationQueue.main.addOperation { [unowned self] in
                    
                    //update data
                    self?.eventData = eventData
                    
                    //trigger view model update
                    self?.delegate?.viewModelDidUpdate()
                    
                    //nilling reference to json loading operation
                    self?.eventsLoadingOperation = nil
                    
                    print("events loading operation did finish successfully")
                }
            }
            self.eventsLoadingOperation?.resume()
        }
    }
}
