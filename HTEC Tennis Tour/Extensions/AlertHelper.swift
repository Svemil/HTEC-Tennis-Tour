//
//  AlertHelper.swift
//  HTEC Tennis Tour
//
//  Created by Svemil Djusic on 20/04/2021.
//

import Foundation
import UIKit

class AlertHelper {
    
    class func showAlertMessage(message: String, viewController: UIViewController) {
        
        DispatchQueue.main.async {
            
            let alertMessage = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
            let cancelAlert = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertMessage.addAction(cancelAlert)
        
        viewController.present(alertMessage, animated: true, completion: nil)
        }
    }
}
