//
//  DateInputViewController.swift
//  CarBooking
//
//  Created by De MicheliStefano on 22.01.19.
//  Copyright © 2019 De MicheliStefano. All rights reserved.
//

import UIKit

/**
 A date input with two input fields which allows users to input start date and number of days.
 */

class DateInputViewController: UIViewController {
    
    enum InputTypes: String {
        case startDate, days
    }
    
    // MARK: - Properties
    lazy var startDate: Date = defaultDate()
    
    private var mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = Constants.defaultSpacing
        return stackView
    }()
    
    private lazy var startDateInputField: PickerInputField = {
        let pf = PickerInputField()
        pf.picker.setDate(startDate, animated: false)
        pf.picker.datePickerMode = .dateAndTime
        pf.picker.locale = Locale(identifier: Locale.current.identifier)
        pf.picker.addTarget(self, action: #selector(didChangeStartDate(picker:)), for: .valueChanged)
        pf.leftImage = UIImage(named: "timer")!
        pf.textColor = .white
        return pf
    }()
    
    private let endDateInputField: PickerInputField = {
        let pf = PickerInputField()
        pf.picker.datePickerMode = .date
        pf.picker.locale = Locale(identifier: Locale.current.identifier)
        let maxDate = Calendar.current.date(byAdding: .day, value: 7, to: Date())
        pf.picker.maximumDate = maxDate
        pf.leftImage = UIImage(named: "clock")!
        pf.tintColor = .red
        pf.textColor = .white
        return pf
    }()
    
    private var startDateLabel: UILabel = {
        let label = UILabel()
        label.text = "Start date"
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    private var endDateLabel: UILabel = {
        let label = UILabel()
        label.text = "End date"
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
    }
    
    // MARK: - Configuration
    private func setupViews() {
        view.addSubview(mainStackView)
        mainStackView.fillSuperview()
        
        let startDateStackView = UIStackView()
        startDateStackView.axis = .vertical
        startDateStackView.distribution = .fillProportionally
        startDateStackView.addArrangedSubview(startDateLabel)
        startDateStackView.addArrangedSubview(startDateInputField)
        
        let endDateStackView = UIStackView()
        endDateStackView.axis = .vertical
        endDateStackView.distribution = .fillProportionally
        endDateStackView.addArrangedSubview(endDateLabel)
        endDateStackView.addArrangedSubview(endDateInputField)
        
        mainStackView.addArrangedSubview(startDateStackView)
        mainStackView.addArrangedSubview(endDateStackView)
        
        startDateInputField.text = formatToString(startDate)
        endDateInputField.text = formatToString(startDate)
        endDateInputField.picker.minimumDate = startDate
    }
    
    // MARK: - Date handlers
    private func defaultDate() -> Date {
        // Sets date to a default value of next day at 9:00am
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        let defaultStartDate = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: tomorrow)!
        return defaultStartDate
    }
    
    private func formatToString(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        dateFormatter.locale = Locale(identifier: Locale.current.identifier)
        return dateFormatter.string(from: date)
    }
    
    @objc private func didChangeStartDate(picker: UIDatePicker) {
        let startDate = picker.date
        endDateInputField.picker.minimumDate = startDate
        endDateInputField.picker.maximumDate = Calendar.current.date(byAdding: .day, value: 7, to: startDate)
        if startDate > endDateInputField.picker.date {
            endDateInputField.picker.date = startDate
            endDateInputField.text = formatToString(startDate)
        }
    }

}