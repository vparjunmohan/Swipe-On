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
        
        AF.request("https://pixabay.com/api/?key=30936526-e786bc4c469026f636558956e&q=yellow+flowers&image_type=photo&orientation=vertical&min_width=1080&min_height=1920").responseJSON(completionHandler: { [self] response in
            switch response.result {
            case .success:
                print("success")
                if let responseValue = response.value as? [String: Any], let hits = responseValue["hits"] as? [[String:Any]]{
                    for hit in hits {
                        if let imageURL = hit["largeImageURL"] as? String {
                            self.imageURLArray.append(imageURL)
                        }
                    }
                }
                view.addSubview(addSwipeView())
                let subviews = view.subviews
                for view in subviews{
                    if view.accessibilityIdentifier == "swipeView" {
                        retrieveImageFromURL(currentSwipeView: view)
                    }
                }
                break
            default:
                break
            }
            
        } )
        
        
    }
    
    func retrieveImageFromURL(currentSwipeView: UIView){
        if imageURLArray.count > 5 {
            // display image in image view
            let image = imageURLArray[0]
            if let currentImageView = currentSwipeView.viewWithTag(100) as? UIImageView{
                currentImageView.downloaded(from: image)
            }
        } else {
            // perform API call
            imageURLArray.remove(at: 0)
            AF.request("https://pixabay.com/api/?key=30936526-e786bc4c469026f636558956e&q=yellow+flowers&image_type=photo&orientation=vertical&page=2&min_width=1080&min_height=1920").responseJSON(completionHandler: { [self] response in
                switch response.result {
                case .success:
                    if let responseValue = response.value as? [String: Any], let hits = responseValue["hits"] as? [[String:Any]]{
                        for hit in hits {
                            if let imageURL = hit["largeImageURL"] as? String {
                                self.imageURLArray.append(imageURL)
                            }
                        }
                    }
                    let image = imageURLArray[0]
                    if let currentImageView = currentSwipeView.viewWithTag(100) as? UIImageView{
                        currentImageView.downloaded(from: image)
                    }
                    break
                default:
                    break
                }
            } )
        }
    }
    
    func createDownloadButton() -> UIButton {
        let download = UIButton()
        download.tag = 9876123
        download.translatesAutoresizingMaskIntoConstraints = false
        download.setImage(UIImage(systemName: "arrow.down"), for: .normal)
        download.layer.cornerRadius = 25
        download.backgroundColor = .white
        download.layer.borderColor = UIColor.blue.cgColor
        download.addTarget(self, action: #selector(didClickDownloadButton(_:)), for: .touchUpInside)
        download.layer.borderWidth = 1
        download.tintColor = UIColor.blue
        return download
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
        swipeView.accessibilityIdentifier = "swipeView"
        swipeView.layer.cornerRadius = 10
        swipeView.layer.shadowColor = color.cgColor
        swipeView.applyCommonDropShadow(radius: 5, opacity: 1)
        swipeView.alpha = 0
        swipeView.frame = CGRect(x: (view.center.x)-(viewWidth/2), y: (view.center.y)-(viewHeight/2), width: viewWidth, height: viewHeight)
        view.addSubview(createDownloadButton())
        if let downloadButton = view.viewWithTag(9876123) as? UIButton {
            downloadButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            downloadButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100).isActive = true
            downloadButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
            downloadButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        }
        
        setupImageContent(parentView: swipeView)
//        retrieveImageFromURL(currentSwipeView: swipeView)
        
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
    
    @objc func didClickDownloadButton(_ sender: UIButton){
        let buttonBounds = sender.bounds
        var buttonMaxY = buttonBounds.maxY
        
        repeat {
            let shapeLayer = CAShapeLayer()
            let aPath = UIBezierPath()
            aPath.move(to: CGPoint(x:buttonBounds.minX, y:buttonMaxY-1))
            aPath.addLine(to: CGPoint(x: buttonBounds.maxX, y: buttonMaxY))

           // Keep using the method addLine until you get to the one where about to close the path
//            aPath.close()

           // If you want to stroke it with a red color
//            UIColor.red.set()
//            aPath.lineWidth = 1.0
//            aPath.stroke()
            
            shapeLayer.path = aPath.cgPath
            shapeLayer.fillColor = UIColor.red.cgColor
            shapeLayer.lineWidth = 1.0
            
            if let button = view.viewWithTag(9876123) as? UIButton {
                button.layer.addSublayer(shapeLayer)
            }
          
            buttonMaxY -= 1
        } while (buttonMaxY == buttonBounds.minY)
        
//        UIView.animate(withDuration: 2.25, delay: 0.0, options: UIView.AnimationOptions.curveEaseInOut, animations: { [self] () -> Void in
//
//        })
    }
    
    @objc func viewIsSwipped(_ sender: UISwipeGestureRecognizer){
        print(imageURLArray.count)
        let currentSwipeView = sender.view!
        var currentSwipeFrame = currentSwipeView.frame
        let defaults = UserDefaults.standard
        let angle: CGFloat = 45.0 * CGFloat.pi / 180.0
        
        if let currentSwipeTag = defaults.object(forKey: "viewTag") as? Int{
            defaults.set(currentSwipeTag+1, forKey: "viewTag")
        }
        let newSwipeView = addSwipeView()
        newSwipeView.isUserInteractionEnabled = false
        view.addSubview(newSwipeView)
//        retrieveImageFromURL(currentSwipeView: newSwipeView)
        imageURLArray.remove(at: 0)
        
        switch sender.direction {
        case .left:
            retrieveImageFromURL(currentSwipeView: newSwipeView)
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
            retrieveImageFromURL(currentSwipeView: newSwipeView)
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
