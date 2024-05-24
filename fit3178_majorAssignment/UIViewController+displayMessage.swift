//
//  UIViewController+displayMessage.swift
//  fit3178_lab3
//
//  Created by Chin Yen Tung on 18/3/2024.
//

import UIKit

extension UIViewController {
    
    // display message method with handler
    // params: title, message, completion
    func displayMessage(title: String, message: String){
        // When creating a UIAlertController we specify the title, message, and preferred UI style.
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        // dismiss button
        // action here specifies nil for the handler
        // We can optionally provide a closure here, i.e., some code to run when the button is pressed
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
}
