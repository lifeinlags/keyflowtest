//
//  EventTableViewCell.swift
//  keyflowtest
//
//  Created by Yana Perekrestova on 25.05.2021.
//

import UIKit

private var AssociatedObjectHandle: UInt8 = 0

//extension to support basic loading of images
extension UIImageView {
    
    var imageDownloadingTask: URLSessionDataTask? {
        get {
            return objc_getAssociatedObject(self, &AssociatedObjectHandle) as? URLSessionDataTask
        }
        set {
            objc_setAssociatedObject(self, &AssociatedObjectHandle, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    func downloaded(from url: URL, contentMode: ContentMode) {
        
        self.contentMode = contentMode
        
        imageDownloadingTask?.cancel()
        imageDownloadingTask = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
            else { return }
            DispatchQueue.main.async() { [weak self] in
                self?.image = image
            }
        }
        imageDownloadingTask?.resume()
    }
    
    func downloaded(from link: String, contentMode mode: ContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloaded(from: url, contentMode: mode)
    }
    
    func cancelCurrentImageLoad() {
        imageDownloadingTask?.cancel()
        imageDownloadingTask = nil
    }
}

class EventTableViewCell: UITableViewCell {

    // MARK: Outlets
    
    @IBOutlet private var bgView: UIView?
    
    @IBOutlet private var eventNameLabel: UILabel?
    @IBOutlet private var venueNameLabel: UILabel?
    
    @IBOutlet private var eventImageView: UIImageView?
    
    @IBOutlet private var eventDateBackgroundView: UIView?
    @IBOutlet private var eventDateLabel: UILabel?
    
    // MARK: Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        bgView?.backgroundColor = UIColor(white: 0.97, alpha: 1.0)
        eventDateBackgroundView?.backgroundColor = UIColor(white: 0.92, alpha: 1.0)
        eventImageView?.backgroundColor = UIColor(white: 0.0, alpha: 1.0)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        //reset labels
        eventNameLabel?.text = ""
        venueNameLabel?.text = ""
        
        eventImageView?.cancelCurrentImageLoad()
        eventImageView?.image = nil
    }

    func setup(eventName: String, venueName: String, startDate: Date, endDate: Date, imageUrl: String?) {
        
        //update labels
        eventNameLabel?.text = eventName
        venueNameLabel?.text = venueName
 
        let startDateFormatter = DateFormatter()
        startDateFormatter.dateFormat = "EEE\ndd\nMMM\nHH:mm"
        
        let endDateFormatter = DateFormatter()
        endDateFormatter.dateFormat = "HH:mm"
        
        eventDateLabel?.text = startDateFormatter.string(from: startDate) + " - " + endDateFormatter.string(from: endDate)
        
        //update image
        if let imageUrl = imageUrl {
            eventImageView?.downloaded(from: imageUrl, contentMode: .scaleAspectFill)
        } else {
            eventImageView?.image = nil
        }
    }
    
    // MARK: - Reusing
    
    static var nib: UINib {
        return UINib(nibName: "\(self)", bundle: nil)
    }
    
    static var reuseIdentifier: String {
        return "\(self)"
    }
    
    // MARK: - Selection
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
