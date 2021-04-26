//
//  UIView.swift
//  HTEC Tennis Tour
//
//  Created by Svemil Djusic on 17/04/2021.
//

import UIKit

extension UIView {
    
    static var name: String {
        return String(describing: self)
    }
}

extension UITextField {
    
    func addDoneButtonOnKeyBoardWithControl() {
        let keyboardToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 40))
        
    keyboardToolbar.sizeToFit()
    keyboardToolbar.barStyle = .default
        
    let flexBarButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    let doneBarButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.endEditing(_:)))
    keyboardToolbar.items = [flexBarButton, doneBarButton]
        
    self.inputAccessoryView = keyboardToolbar
    }
}
