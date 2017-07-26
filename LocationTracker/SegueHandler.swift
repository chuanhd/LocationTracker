//
//  SegueHandler.swift
//  LocationTracker
//
//  Created by Chuan Ho Danh on 7/26/17.
//  Copyright © 2017 tranght. All rights reserved.
//

import Foundation
import UIKit

protocol SegueHandler {
    associatedtype SegueIdentifier : RawRepresentable
}

extension SegueHandler where Self : UIViewController, SegueIdentifier.RawValue == String {
    func segueIdentifier(for segue: UIStoryboardSegue) -> SegueIdentifier {
        guard let identifier = segue.identifier,
            let segueIdentifier = SegueIdentifier(rawValue: identifier)
        else {
            fatalError("Identifier not define")
        }
    
        return segueIdentifier
    }
}
