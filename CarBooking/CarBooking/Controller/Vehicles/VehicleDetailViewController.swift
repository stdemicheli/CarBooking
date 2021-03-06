//
//  VehicleDetailViewController.swift
//  CarBooking
//
//  Created by De MicheliStefano on 21.01.19.
//  Copyright © 2019 De MicheliStefano. All rights reserved.
//

import UIKit

/**
 A view controller that shows details of a vehicle and lets users book a vehicle.
 */

class VehicleDetailViewController: UIViewController {
    
    // MARK: - Properties
    var vehicle: VehicleRepresentation {
        didSet {
            setupViews()
        }
    }
    /// A controller that handles loading vehicles from network.
    let vehicleController: VehicleController?
    /// A controller that handles loading and saving bookings.
    let bookingController: BookingController
    /// The start date the user wishes to book a vehicle.
    var bookingStartDate: Date?
    /// The end date the user wishes to book a vehicle.
    var bookingEndDate: Date?
    /// A boolean indicating whether the vehicle has been booked.
    var hasBooked: Bool = false
    
    /// A profile view for showing images and description 
    private var profileView: ProfileView!
    // TODO: Dependency injection instead of instatiating here:
    private let dateInputVC = DateInputViewController()
    private let notificationHelper = LocalNotificationHelper()
    private var padding = Constants.defaultPadding
    
    /// Booking button that allows the user to confirm a booking.
    private var bookingButton: UIButton = {
        let button = UIButton(type: .system)
        let buttonTitle = NSLocalizedString("Book Now", comment: "A button title as a call to action for the user to book the vehicle.")
        button.setTitle("Book Now", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20.0)
        button.layer.cornerRadius = 25
        button.layer.masksToBounds = true
        button.backgroundColor = UIColor.accent
        button.tintColor = .white
        button.addTarget(self, action: #selector(handleBooking), for: .touchUpInside)
        return button
    }()
    
    /// A loader indicator.
    private var spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .whiteLarge)
        spinner.frame = CGRect(x: -20.0, y: 6.0, width: 10.0, height: 10.0)
        spinner.alpha = 0.0
        return spinner
    }()
    
    // MARK: - Init
    init(vehicleController: VehicleController? = nil, vehicle: VehicleRepresentation, bookingController: BookingController) {
        self.vehicleController = vehicleController
        self.bookingController = bookingController
        self.vehicle = vehicle
        // If no vehicle controller has been passed in it means we instantiated from BookingVC.
        if vehicleController == nil { hasBooked = true }
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        loadDetails()
        setupViews()
    }
    
    // MARK: - Configuration
    private func setupViews() {
        // Setup view controller
        title = hasBooked
            ? NSLocalizedString("Your booking", comment: "A title that indicates that the detail view is a booked vehicle.")
            : NSLocalizedString("Make a booking", comment: "A call for action for the user to book a vehicle.")
        edgesForExtendedLayout = []
        view.backgroundColor = UIColor.primary
        dateInputVC.delegate = self
        
        guard let imagePath = vehicle.image else { return }
        
        // Setup profile view
        let aDescription = (UIDevice.current.userInterfaceIdiom == .pad ? vehicle.descript : vehicle.shortDescript) ?? ""
        let imageUrl = URL(string: imagePath, relativeTo: Constants.vehicleBaseUrl)
        let image = UIImage.download(from: imageUrl)
        profileView = ProfileView(image: image, title: vehicle.name, description: aDescription)
        view.addSubview(profileView)
        profileView.anchor(top: view.topAnchor,
                           leading: view.leadingAnchor,
                           bottom: nil,
                           trailing: view.trailingAnchor,
                           padding: UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding))
        profileView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.65).isActive = true
        
        // Setup date input view
        add(dateInputVC)
        view.addSubview(dateInputVC.view)
        dateInputVC.view.anchor(top: profileView.bottomAnchor,
                                leading: view.leadingAnchor,
                                bottom: nil,
                                trailing: view.trailingAnchor,
                                padding: UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding))
        dateInputVC.view.heightAnchor.constraint(equalToConstant: 70).isActive = true
        
        // Setup booking button
        view.addSubview(bookingButton)
        bookingButton.addSubview(spinner)
        spinner.centerInSuperview(size: CGSize(width: 10, height: 10))
        let bottomPadding = UIDevice.current.userInterfaceIdiom == .pad ? 80 : padding
        bookingButton.anchor(top: nil,
                             leading: view.leadingAnchor,
                             bottom: view.bottomAnchor,
                             trailing: view.trailingAnchor,
                             padding: UIEdgeInsets(top: padding, left: padding, bottom: bottomPadding, right: padding))
        bookingButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        updateViewsOnFinishedBooking()
    }
    
    /// Updates the view when the vehicle has already been booked.
    private func updateViewsOnFinishedBooking() {
        guard hasBooked == true else { return }
        // Deactivate date inputs.
        dateInputVC.deactivateInput()
        bookingButton.backgroundColor = UIColor.correctGreen
        let buttonTitle = NSLocalizedString("Booked!", comment: "A button title indicating that the vehicle has been booked.")
        bookingButton.setTitle(buttonTitle, for: .normal)
        bookingButton.isUserInteractionEnabled = false
    }
    
    // MARK: - Networking
    /// Fetches vehicle details from the network.
    private func loadDetails() {        
        vehicleController?.loadDetail(for: vehicle.identifier,completion: { (response) in
            DispatchQueue.main.async {
                switch response {
                case .success(let vehicleDetails):
                    self.vehicle = vehicleDetails
                case .error(_):
                    NSLog("Could not fetch vehicles")
                }
            }
        })
    }
    
    /// Saves a booking to local persistence and to the network.
    private func book(_ vehicle: VehicleRepresentation, from startDate: Date, to endDate: Date) {
        bookingController.book(vehicle, from: startDate, to: endDate, completion: { (response) in
            DispatchQueue.main.async {
                switch response {
                case .success(_):
                    self.bookingDidFinish()
                case .error(let error):
                    NSLog("Error saving booking: \(error)")
                    self.bookingDidFinish()
                }
            }
        })
    }
    
    // MARK: - User actions
    /// Saves a booking and shows a loading animation.
    @objc private func handleBooking() {
        guard let startDate = bookingStartDate, let endDate = bookingEndDate else {
            NSLog("No start or end dates picked")
            return
        }
        
        book(vehicle, from: startDate, to: endDate)
        
        spinner.startAnimating()
        self.bookingButton.setTitleColor(UIColor.clear, for: .normal)
        UIView.animate(withDuration: 0.33) {
            self.spinner.alpha = 1.0
        }
    }
    
    /// Reverses the loading animation upon completion of saving the booking.
    private func bookingDidFinish() {
        spinner.stopAnimating()
        self.bookingButton.setTitleColor(.white, for: .normal)
        UIView.animate(withDuration: 0.33) {
            self.spinner.alpha = 0.0
        }
        hasBooked = true
        updateViewsOnFinishedBooking()
    }
    
    // MARK: - Helper functions
    
    
}

// MARK: - DateInputVCDelegate
extension VehicleDetailViewController: DateInputDelegate {
    
    /// Updates start and end dates whenever a user picks a new date.
    func dateInput(_ dateInput: DateInputViewController, didSelect dates: DateInputViewController.InputDates) {
        bookingStartDate = dates.startDate
        bookingEndDate = dates.endDate
    }
    
}
