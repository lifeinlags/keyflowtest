//
//  EventListViewController.swift
//  keyflowtest
//
//  Created by Yana Perekrestova on 24.05.2021.
//

import UIKit

final class EventListViewController: UIViewController, EventListViewModelDelegate {

    // MARK: - ViewModel
    
    private var viewModel: EventListViewModel?
    
    // MARK: - Outlets
    
    @IBOutlet private var tableView: UITableView?
    private var refreshControl: UIRefreshControl?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Stockholm"

        viewModel = EventListViewModel(delegate: self)
        
        tableView?.register(EventTableViewCell.nib, forCellReuseIdentifier: EventTableViewCell.reuseIdentifier)
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(refreshControlDidTrigger(_:)), for: .valueChanged)
        tableView?.refreshControl = refreshControl
        
        // Do any additional setup after loading the view.
        viewModel?.reloadEvents()
    }

    // MARK: - Actions
    
    @objc private func refreshControlDidTrigger(_ sender: AnyObject?) {
        viewModel?.reloadEvents()
    }
    
    // MARK: - ViewModel Delegate
    
    func viewModelDidUpdate() {
        
        //reload on main thread
        OperationQueue.main.addOperation { [weak self] in
            
            //reloading with animation
            self?.tableView?.reloadSections(IndexSet(integer: 0), with: .fade)
        }
    }

    func loadingDidBegin() {
        OperationQueue.main.addOperation { [unowned self] in
            guard let refreshControl = self.refreshControl, refreshControl.isRefreshing else { return }
            refreshControl.beginRefreshing()
        }
    }
    
    func loadingDidFinish() {
        OperationQueue.main.addOperation { [unowned self] in
            self.refreshControl?.endRefreshing()
        }
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
}

// MARK: UITableView Setup

extension EventListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.eventData?.combinedEvents.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //dequeue event cell
        guard let eventCell = tableView.dequeueReusableCell(withIdentifier: EventTableViewCell.reuseIdentifier, for: indexPath) as? EventTableViewCell else { return UITableViewCell() }
        
        guard let combinedEvent = viewModel?.eventData?.combinedEvents[indexPath.row] else { return UITableViewCell() }
        
        eventCell.setup(eventName: combinedEvent.event.name,
                        venueName: "\(combinedEvent.venue.venueName)",
                        startDate: combinedEvent.event.startDate,
                        endDate: combinedEvent.event.endDate,
                        imageUrl: combinedEvent.event.images.first)
        
        return eventCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
