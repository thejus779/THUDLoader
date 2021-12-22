//
//  THUDContainer.swift
//  Loader
//
//  Created by Thejus Thejus on 14/12/2021.
//

import UIKit
internal class FrameView: UIVisualEffectView {

    internal init() {
        super.init(effect: UIBlurEffect(style: .light))
        DispatchQueue.main.async {
            self.commonInit()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        DispatchQueue.main.async {
            self.commonInit()
        }
    }

    private func commonInit() {
        //Frosted effect
        backgroundColor = UIColor(white: 0.8, alpha: 0.25)
        
        layer.cornerRadius = 10.0
        layer.masksToBounds = true

        contentView.addSubview(content)

        let offset = 40

        let motionEffectsX = UIInterpolatingMotionEffect(keyPath: "center.x", type: .tiltAlongHorizontalAxis)
        motionEffectsX.maximumRelativeValue = offset
        motionEffectsX.minimumRelativeValue = -offset

        let motionEffectsY = UIInterpolatingMotionEffect(keyPath: "center.y", type: .tiltAlongVerticalAxis)
        motionEffectsY.maximumRelativeValue = offset
        motionEffectsY.minimumRelativeValue = -offset

        let group = UIMotionEffectGroup()
        group.motionEffects = [motionEffectsX, motionEffectsY]

        addMotionEffect(group)
    }

    private var actualContent = UIView()
    internal var content: UIView {
        get {
            return actualContent
        }
        set {
            actualContent.removeFromSuperview()
            actualContent = newValue
            actualContent.alpha = 0.8
            actualContent.clipsToBounds = true
            actualContent.contentMode = .center
            frame.size = actualContent.bounds.size
            contentView.addSubview(actualContent)
        }
    }
}

internal class ContainerView: UIView {

    private var keyboardIsVisible = false
    private var keyboardHeight: CGFloat = 0.0
    
    internal let frameView: FrameView
    internal init(frameView: FrameView = FrameView()) {
        self.frameView = frameView
        super.init(frame: CGRect.zero)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        frameView = FrameView()
        super.init(coder: aDecoder)
        commonInit()
    }

    fileprivate func commonInit() {
        backgroundColor = UIColor.clear
        isHidden = true

        addSubview(backgroundView)
        addSubview(frameView)
    }

    internal override func layoutSubviews() {
        super.layoutSubviews()

        frameView.center = calculateHudCenter()
        backgroundView.frame = bounds
    }
    
    

    internal func showFrameView() {
        layer.removeAllAnimations()
        frameView.center = calculateHudCenter()
        frameView.alpha = 1.0
        isHidden = false
    }

    fileprivate var willHide = false

    internal func hideFrameView(animated anim: Bool, completion: ((Bool) -> Void)? = nil) {
        let finalize: (_ finished: Bool) -> Void = { finished in
            self.isHidden = true
            self.removeFromSuperview()
            self.willHide = false

            completion?(finished)
        }

        if isHidden {
            return
        }

        willHide = true

        if anim {
            UIView.animate(withDuration: 0.8, animations: {
                self.frameView.alpha = 0.0
                self.hideBackground(animated: false)
            }, completion: { _ in finalize(true) })
        } else {
            self.frameView.alpha = 0.0
            finalize(true)
        }
    }

    fileprivate let backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.0, alpha: 0.25)
        view.alpha = 0.0
        return view
    }()

    internal func showBackground(animated anim: Bool) {
        if anim {
            UIView.animate(withDuration: 0.175, animations: {
                self.backgroundView.alpha = 1.0
            })
        } else {
            backgroundView.alpha = 1.0
        }
    }

    internal func hideBackground(animated anim: Bool) {
        if anim {
            UIView.animate(withDuration: 0.65, animations: {
                self.backgroundView.alpha = 0.0
            })
        } else {
            backgroundView.alpha = 0.0
        }
    }
    
    // MARK: Notifications
    internal func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    internal func deregisterFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // MARK: Triggered Functions
    @objc private func keyboardWillShow(notification: NSNotification) {
        keyboardIsVisible = true
        guard let userInfo = notification.userInfo else {
            return
        }
        if let keyboardHeight = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.height {
            self.keyboardHeight = keyboardHeight
        }
        if !self.isHidden {
            if let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber,
                let curve = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber {
                animateHUDWith(duration: duration.doubleValue,
                               curve: UIView.AnimationCurve(rawValue: curve.intValue) ?? UIView.AnimationCurve.easeInOut,
                               toLocation: calculateHudCenter())
            }
        }
    }
    
    @objc private func keyboardWillBeHidden(notification: NSNotification) {
        keyboardIsVisible = false
        if !self.isHidden {
            guard let userInfo = notification.userInfo else {
                return
            }
            if let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber,
                let curve = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber {
                animateHUDWith(duration: duration.doubleValue,
                               curve: UIView.AnimationCurve(rawValue: curve.intValue) ?? UIView.AnimationCurve.easeInOut,
                               toLocation: calculateHudCenter())
            }
        }
    }
    
    // MARK: - Helpers
    private func animateHUDWith(duration: Double, curve: UIView.AnimationCurve, toLocation location: CGPoint) {
        UIView.animate(
            withDuration: TimeInterval(duration),
            delay: TimeInterval(0),
            options: .curveEaseInOut,
            animations: { [weak self] in
                self?.frameView.center = location
            },
            completion: nil
        )
    }
    
    private func calculateHudCenter() -> CGPoint {
        if !keyboardIsVisible {
            return center
        } else {
            let yLocation = (frame.height - keyboardHeight) / 2
            return CGPoint(x: center.x, y: yLocation)
        }
    }
}
