//
//  VehicleRepresentation.swift
//  CarBooking
//
//  Created by De MicheliStefano on 18.01.19.
//  Copyright © 2019 De MicheliStefano. All rights reserved.
//

import Foundation

/**
 A vehicle representation model which represents a vehicle parsed from a JSON object.
 */

struct VehicleRepresentation: Codable {
    
    let identifier: Int16
    let name: String
    let shortDescript: String?
    let descript: String?
    let image: String?
    
//    init(id: Int16, name: String, shortDescript: String, descript: String, image: String) {
//        self.identifier = id
//        self.name = name
//    }
    
    enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case name
        case shortDescript = "shortDescription"
        case descript = "description"
        case image
    }
    
}
