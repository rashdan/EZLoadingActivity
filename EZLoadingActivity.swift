//
//  EZLoadingActivity.swift
//  EZLoadingActivity
//
//  Created by Goktug Yilmaz on 02/06/15.
//  Copyright (c) 2015 Goktug Yilmaz. All rights reserved.
//

import UIKit

public struct EZLoadingActivity {
    
    //==========================================================================================================
    // Feel free to edit these variables
    //==========================================================================================================
    public struct Settings {
        public static var BackgroundColor = UIColor(red: 227/255, green: 232/255, blue: 235/255, alpha: 1.0)
        public static var BackgroundColorWithBlurEffect = UIColor.clear
        public static var ActivityColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1.0)
        public static var TextColor = UIColor(red: 80/255, green: 80/255, blue: 80/255, alpha: 1.0)
        public static var TextColorWithBlurEffect = UIColor.white
        public static var ActivityColorWithBlurEffect =  UIColor.white
        public static var FontName = "HelveticaNeue-Light"
        // Other possible stuff: ✓ ✓ ✔︎ ✕ ✖︎ ✘
        public static var SuccessIcon = "✔︎"
        public static var FailIcon = "✘"
        public static var SuccessText = "Success"
        public static var FailText = "Failure"
        public static var SuccessColor = UIColor(red: 68/255, green: 118/255, blue: 4/255, alpha: 1.0)
        public static var FailColor = UIColor(red: 255/255, green: 75/255, blue: 56/255, alpha: 1.0)
        static var WidthDivision: CGFloat {
            get {
                if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad {
                    return  3.5
                } else {
                    return 1.6
                }
            }
        }
    }
    
    fileprivate static var instance: LoadingActivity?
    fileprivate static var hidingInProgress = false
    
    /// Disable UI stops users touch actions until EZLoadingActivity is hidden. Return success status
    public static func show(_ text: String, disableUI: Bool) -> Bool {
        guard instance == nil else {
            print("EZLoadingActivity: You still have an active activity, please stop that before creating a new one")
            return false
        }
        
        guard topMostController != nil else {
            print("EZLoadingActivity Error: You don't have any views set. You may be calling them in viewDidLoad. Try viewDidAppear instead.")
            return false
        }
        
        instance = LoadingActivity(text: text, disableUI: disableUI)
        return true
    }
    
    public static func show(_ text: String, disableUI: Bool,blurBackground:Bool,topPadding:Bool) -> Bool {
        guard instance == nil else {
            print("EZLoadingActivity: You still have an active activity, please stop that before creating a new one")
            return false
        }
        
        guard topMostController != nil else {
            print("EZLoadingActivity Error: You don't have any views set. You may be calling them in viewDidLoad. Try viewDidAppear instead.")
            return false
        }
        if(blurBackground){
            instance = LoadingActivity(text: text, disableUI: disableUI, blurBackground:blurBackground, topPadding:topPadding)
        }
        else{
            instance = LoadingActivity(text: text, disableUI: disableUI)
        }
        
        return true
    }
    
    public static func showWithDelay(_ text: String, disableUI: Bool, seconds: Double) -> Bool {
        let showValue = show(text, disableUI: disableUI)
        delay(seconds) { () -> () in
            _ = hide(success: true, animated: false)
        }
        return showValue
    }
    
    /// Returns success status
    public static func hide(success: Bool? = nil, animated: Bool = false) -> Bool {
        guard instance != nil else {
            print("EZLoadingActivity: You don't have an activity instance")
            return false
        }
        
        guard hidingInProgress == false else {
            print("EZLoadingActivity: Hiding already in progress")
            return false
        }
        
        if !Thread.current.isMainThread {
            DispatchQueue.main.async {
                instance?.hideLoadingActivity(success: success, animated: animated)
            }
        } else {
            instance?.hideLoadingActivity(success: success, animated: animated)
        }
        
        return true
    }
    
    fileprivate static func delay(_ seconds: Double, after: @escaping ()->()) {
        let queue = DispatchQueue.main
        let time = DispatchTime.now() + Double(Int64(seconds * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        queue.asyncAfter(deadline: time, execute: after)
    }
    
    fileprivate class LoadingActivity: UIView {
        var textLabel: UILabel!
        var activityView: UIActivityIndicatorView!
        var icon: UILabel!
        var UIDisabled = false
        var blurBackground = false
        
        convenience init(text: String, disableUI: Bool) {
            let width = UIScreen.ScreenWidth / Settings.WidthDivision
            let height = width / 3
            self.init(frame: CGRect(x: UIScreen.ScreenWidth/2 - width/2, y: UIScreen.ScreenHeight/2 - height/2, width: width, height: height))
            backgroundColor = Settings.BackgroundColor
            alpha = 1
            layer.cornerRadius = 8
            createShadow()
            
            let yPosition = frame.height/2 - 20
            
            activityView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
            activityView.frame = CGRect(x: 10, y: yPosition, width: 40, height: 40)
            activityView.color = Settings.ActivityColor
            activityView.startAnimating()
            
            
            textLabel = UILabel(frame: CGRect(x: 60, y: yPosition, width: width - 70, height: 40))
            textLabel.textColor = Settings.TextColor
            textLabel.font = UIFont(name: Settings.FontName, size: 30)
            textLabel.adjustsFontSizeToFitWidth = true
            textLabel.minimumScaleFactor = 0.25
            textLabel.textAlignment = NSTextAlignment.center
            textLabel.text = text
            
            addSubview(activityView)
            addSubview(textLabel)
            
            topMostController!.view.addSubview(self)
            
            if disableUI {
                UIApplication.shared.beginIgnoringInteractionEvents()
                UIDisabled = true
            }
        }
        
        convenience init(text: String, disableUI: Bool,blurBackground:Bool,topPadding:Bool) {
            
            
            let width = UIScreen.ScreenWidth / Settings.WidthDivision
            _ = width / 3
            var yPositionForView:CGFloat =  0
            if(topPadding){yPositionForView = 64}
            
            self.init(frame: CGRect(x: 0, y: yPositionForView, width: UIScreen.ScreenWidth, height: UIScreen.ScreenHeight))
            backgroundColor = Settings.BackgroundColorWithBlurEffect
            
            let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
            let blurEffectView:UIVisualEffectView = UIVisualEffectView(effect: blurEffect)
            blurEffectView.frame = self.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            blurEffectView.alpha = 0.8
            
            var yPosition:CGFloat = frame.height/2 - 20
            let xPosition = frame.width/2 - 85
            
            if(topPadding){yPosition -= 64}
            
            activityView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
            activityView.frame = CGRect(x: xPosition, y: yPosition, width: 40, height: 40)
            activityView.color = Settings.ActivityColorWithBlurEffect
            activityView.startAnimating()
            
            textLabel = UILabel(frame: CGRect(x: xPosition+50, y: yPosition, width: width - 70, height: 40))
            textLabel.textColor = Settings.TextColorWithBlurEffect
            textLabel.font = UIFont(name: Settings.FontName, size: 30)
            textLabel.adjustsFontSizeToFitWidth = true
            textLabel.minimumScaleFactor = 0.25
            textLabel.textAlignment = NSTextAlignment.center
            textLabel.text = text
            
            blurEffectView.addSubview(textLabel)
            blurEffectView.addSubview(activityView)
            addSubview(blurEffectView)
            
            topMostController!.view.addSubview(self)
            
            if disableUI {
                UIApplication.shared.beginIgnoringInteractionEvents()
                UIDisabled = true
            }
        }
        
        func createShadow() {
            layer.shadowPath = createShadowPath().cgPath
            layer.masksToBounds = false
            layer.shadowColor = UIColor.black.cgColor
            layer.shadowOffset = CGSize(width: 0, height: 0)
            layer.shadowRadius = 5
            layer.shadowOpacity = 0.5
        }
        
        func createShadowPath() -> UIBezierPath {
            let myBezier = UIBezierPath()
            myBezier.move(to: CGPoint(x: -3, y: -3))
            myBezier.addLine(to: CGPoint(x: frame.width + 3, y: -3))
            myBezier.addLine(to: CGPoint(x: frame.width + 3, y: frame.height + 3))
            myBezier.addLine(to: CGPoint(x: -3, y: frame.height + 3))
            myBezier.close()
            return myBezier
        }
        
        func hideLoadingActivity(success: Bool?, animated: Bool) {
            hidingInProgress = true
            if UIDisabled {
                UIApplication.shared.endIgnoringInteractionEvents()
            }
            
            var animationDuration: Double = 0
            if success != nil {
                if success! {
                    animationDuration = 0.5
                } else {
                    animationDuration = 1
                }
            }
            
            icon = UILabel(frame: CGRect(x: 10, y: frame.height/2 - 20, width: 40, height: 40))
            icon.font = UIFont(name: Settings.FontName, size: 60)
            icon.textAlignment = NSTextAlignment.center
            
            if animated {
                textLabel.fadeTransition(animationDuration)
            }
            
            if success != nil {
                if success! {
                    icon.textColor = Settings.SuccessColor
                    icon.text = Settings.SuccessIcon
                    textLabel.text = Settings.SuccessText
                } else {
                    icon.textColor = Settings.FailColor
                    icon.text = Settings.FailIcon
                    textLabel.text = Settings.FailText
                }
            }
            
            addSubview(icon)
            
            if animated {
                icon.alpha = 0
                activityView.stopAnimating()
                UIView.animate(withDuration: animationDuration, animations: {
                    self.icon.alpha = 1
                }, completion: { (value: Bool) in
                    self.callSelectorAsync(#selector(UIView.removeFromSuperview), delay: animationDuration)
                    instance = nil
                    hidingInProgress = false
                })
            } else {
                activityView.stopAnimating()
                self.callSelectorAsync(#selector(UIView.removeFromSuperview), delay: animationDuration)
                instance = nil
                hidingInProgress = false
            }
        }
    }
}

private extension UIView {
    /// Extension: insert view.fadeTransition right before changing content
    func fadeTransition(_ duration: CFTimeInterval) {
        let animation: CATransition = CATransition()
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        animation.type = kCATransitionFade
        animation.duration = duration
        self.layer.add(animation, forKey: kCATransitionFade)
    }
}

private extension NSObject {
    func callSelectorAsync(_ selector: Selector, delay: TimeInterval) {
        let timer = Timer.scheduledTimer(timeInterval: delay, target: self, selector: selector, userInfo: nil, repeats: false)
        RunLoop.main.add(timer, forMode: RunLoopMode.commonModes)
    }
}

private extension UIScreen {
    class var Orientation: UIInterfaceOrientation {
        get {
            return UIApplication.shared.statusBarOrientation
        }
    }
    class var ScreenWidth: CGFloat {
        get {
            if UIInterfaceOrientationIsPortrait(Orientation) {
                return UIScreen.main.bounds.size.width
            } else {
                return UIScreen.main.bounds.size.height
            }
        }
    }
    class var ScreenHeight: CGFloat {
        get {
            if UIInterfaceOrientationIsPortrait(Orientation) {
                return UIScreen.main.bounds.size.height
            } else {
                return UIScreen.main.bounds.size.width
            }
        }
    }
}

private var topMostController: UIViewController? {
    var presentedVC = UIApplication.shared.keyWindow?.rootViewController
    while let pVC = presentedVC?.presentedViewController {
        presentedVC = pVC
    }
    
    return presentedVC
}
