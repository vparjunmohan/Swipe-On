//
//  SwipeViewController.swift
//  Swipe On
//
//  Created by Arjun Mohan on 29/10/22.
//

import UIKit
import Alamofire

class SwipeViewController: UIViewController {
    
    var imageURLArray: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        let defaults = UserDefaults.standard
        
        AF.request("https://pixabay.com/api/?key=30936526-e786bc4c469026f636558956e&image_type=photo&orientation=vertical").responseJSON(completionHandler: { [self] response in
                    switch response.result {
                    case .success:
                        if let responseValue = response.value as? [String: Any], let hits = responseValue["hits"] as? [[String:Any]]{
                            for hit in hits {
                                if let imageURL = hit["largeImageURL"] as? String {
                                    self.imageURLArray.append(imageURL)
                                }
                            }
                        }
                        view.addSubview(addSwipeView())
                        break
                    default:
                        break
                    }

                } )

       
    }
    
    func retrieveImageFromURL(currentSwipeView: UIView){
        let defaults = UserDefaults.standard
        if imageURLArray.count > 0 {
            // display image in image view
            let image = imageURLArray[0]
            if let currentImageView = currentSwipeView.viewWithTag(100) as? UIImageView{
                currentImageView.downloaded(from: image)
            }
        } 
        
        
    }
    
    func addSwipeView() -> UIView {
        let swipeView = UIView()
        let color = UIColor.random()
        let viewHeight = 350.0
        let viewWidth = 250.0
        let defaults = UserDefaults.standard
        if let viewTag = defaults.object(forKey: "viewTag") as? Int {
            swipeView.tag = viewTag
        }
//        swipeView.backgroundColor = color
        swipeView.layer.cornerRadius = 10
        swipeView.layer.shadowColor = color.cgColor
        swipeView.applyCommonDropShadow(radius: 5, opacity: 1)
        swipeView.alpha = 0
        swipeView.frame = CGRect(x: (view.center.x)-(viewWidth/2), y: (view.center.y)-(viewHeight/2), width: viewWidth, height: viewHeight)
        setupImageContent(parentView: swipeView)
        retrieveImageFromURL(currentSwipeView: swipeView)
        
        UIView.animate(withDuration: 0.1, delay: 0.0, options: UIView.AnimationOptions.curveEaseInOut, animations: { () -> Void in
            swipeView.alpha = 1
        })
        let viewSwippedRight = UISwipeGestureRecognizer(target: self, action: #selector(viewIsSwipped(_:)))
        viewSwippedRight.direction = .right
        let viewSwippedLeft = UISwipeGestureRecognizer(target: self, action: #selector(viewIsSwipped(_:)))
        viewSwippedRight.direction = .left
        swipeView.addGestureRecognizer(viewSwippedRight)
        swipeView.addGestureRecognizer(viewSwippedLeft)
        return swipeView
    }
    
    func setupImageContent(parentView: UIView){
        let imageContent = UIImageView()
        imageContent.tag = 100
        imageContent.contentMode = .scaleAspectFill
        parentView.addSubview(imageContent)
        imageContent.frame = CGRect(x: 0, y: 0, width: parentView.frame.width, height: parentView.frame.height)
    }
    
    @objc func viewIsSwipped(_ sender: UISwipeGestureRecognizer){
        let currentSwipeView = sender.view!
        var currentSwipeFrame = currentSwipeView.frame
        let defaults = UserDefaults.standard
        let angle: CGFloat = 45.0 * CGFloat.pi / 180.0
        imageURLArray.remove(at: 0)
        
        if let currentSwipeTag = defaults.object(forKey: "viewTag") as? Int{
            defaults.set(currentSwipeTag+1, forKey: "viewTag")
        }
        let newSwipeView = addSwipeView()
        newSwipeView.isUserInteractionEnabled = false
        view.addSubview(newSwipeView)
        retrieveImageFromURL(currentSwipeView: newSwipeView)
        
        switch sender.direction {
        case .left:
            currentSwipeFrame.origin.x -= 70
            UIView.animate(withDuration: 0.25, delay: 0.0, options: UIView.AnimationOptions.curveEaseInOut, animations: { [self] () -> Void in
                view.bringSubviewToFront(currentSwipeView)
                currentSwipeView.frame = currentSwipeFrame
                let rotationMatrix = CGAffineTransform(rotationAngle: -angle)
                let translationMatrix = CGAffineTransform(translationX: -100.0, y: -angle)
                currentSwipeView.transform = translationMatrix.concatenating(rotationMatrix)
            }) { completed in
                UIView.animate(withDuration: 0.5, delay: 0.0, options: UIView.AnimationOptions.curveEaseOut, animations: { () -> Void in
                    currentSwipeView.alpha = 0
                }) { completed in
                    if let imageContentView = currentSwipeView.viewWithTag(200) as? UIImageView {
                        imageContentView.removeFromSuperview()
                    }
                    
                    currentSwipeView.removeFromSuperview()
                }
                newSwipeView.isUserInteractionEnabled = true
            }
        case .right:
            currentSwipeFrame.origin.x += 70
            UIView.animate(withDuration: 0.25, delay: 0.0, options: UIView.AnimationOptions.curveEaseInOut, animations: { [self] () -> Void in
                view.bringSubviewToFront(currentSwipeView)
                currentSwipeView.frame = currentSwipeFrame
                let rotationMatrix = CGAffineTransform(rotationAngle: angle)
                let translationMatrix = CGAffineTransform(translationX: 100.0, y: 0.0)
                currentSwipeView.transform = translationMatrix.concatenating(rotationMatrix)
            }) { completed in
                UIView.animate(withDuration: 0.5, delay: 0.0, options: UIView.AnimationOptions.curveEaseOut, animations: { () -> Void in
                    currentSwipeView.alpha = 0
                }) { completed in
                    if let imageContentView = currentSwipeView.viewWithTag(200) as? UIImageView {
                        imageContentView.removeFromSuperview()
                    }
                    currentSwipeView.removeFromSuperview()
                }
                newSwipeView.isUserInteractionEnabled = true
            }
        default:
            break
        }
    }
}

extension CGFloat {
    static func random() -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
}

extension UIColor {
    static func random() -> UIColor {
        return UIColor(
            red:   .random(),
            green: .random(),
            blue:  .random(),
            alpha: 1.0
        )
    }
}

extension UIView {
    func applyCommonDropShadow(radius:CGFloat, opacity: Float) {
        layer.shadowOffset = CGSize(width: -1, height: 1)
        layer.shadowRadius = radius
        layer.shadowOpacity = opacity
        layer.borderColor = UIColor.black.cgColor
        clipsToBounds = false
    }
}

extension UIImageView {
    func downloaded(from url: URL, contentMode mode: ContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() { [weak self] in
                self?.image = image
            }
        }.resume()
    }
    func downloaded(from link: String, contentMode mode: ContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloaded(from: url, contentMode: mode)
    }
}
