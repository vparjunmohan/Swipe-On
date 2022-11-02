//
//  AppUtils.swift
//  Swipe On
//
//  Created by Arjun Mohan on 03/11/22.
//

import UIKit

class AppUtils: NSObject {
    
    // Create image view
    func setupImageContent(parentView: UIView){
        let imageContent = UIImageView()
        imageContent.tag = 100
        imageContent.contentMode = .scaleAspectFill
        parentView.addSubview(imageContent)
        imageContent.frame = CGRect(x: 0, y: 0, width: parentView.frame.width, height: parentView.frame.height)
    }

    // Create a toast message view
    func createToast(message: String, parentView: UIView, topView: UIView) {
        let toastLabel = UILabel()
        toastLabel.tag = 101010101
        toastLabel.translatesAutoresizingMaskIntoConstraints = false
        toastLabel.text = message
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        toastLabel.textAlignment = .center
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10
        toastLabel.clipsToBounds  =  true
        parentView.addSubview(toastLabel)
        let downloadButton = topView as! UIButton
        toastLabel.centerXAnchor.constraint(equalTo: parentView.centerXAnchor).isActive = true
        toastLabel.topAnchor.constraint(equalTo: downloadButton.bottomAnchor, constant: 15).isActive = true
        toastLabel.widthAnchor.constraint(equalToConstant: 240).isActive = true
        toastLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseInOut, animations: {
                toastLabel.alpha = 0.5
           }, completion: {(isCompleted) in
               toastLabel.removeFromSuperview()
           })
    }
    
    // Remove toast message view
    func removeCurrentToast(view: UIView){
        if let currentToastView = view.viewWithTag(101010101) {
            currentToastView.removeFromSuperview()
        }
    }
}
