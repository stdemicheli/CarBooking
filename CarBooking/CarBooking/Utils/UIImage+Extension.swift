//
//  UIImageView+Extension.swift
//  CarBooking
//
//  Created by De MicheliStefano on 21.01.19.
//  Copyright © 2019 De MicheliStefano. All rights reserved.
//

import UIKit

extension UIImage {
    
    static func download(from url: URL?) -> UIImage? {
        guard let url = url else { return nil }
        
        do {
            let data = try Data(contentsOf: url)
            return UIImage(data: data)!
        } catch {
            return nil
        }
    }
    
}
