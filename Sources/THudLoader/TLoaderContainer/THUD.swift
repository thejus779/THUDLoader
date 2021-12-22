//
//  THUD.swift
//  Loader
//
//  Created by Thejus Thejus on 14/12/2021.
//

import UIKit

public enum THUDType {
    case success
    case error
    case progress
    case successWith(title: String?, subtitle: String?)
    case errorWith(title: String?, subtitle: String?)
    case progressWith(title: String?, subtitle: String?)
    
}
open class THUD: NSObject {

    fileprivate struct Constants {
        static let sharedHUD = THUD()
    }

    fileprivate let container = ContainerView()
    fileprivate var hideTimer: Timer?

    public typealias TimerAction = (Bool) -> Void
    fileprivate var timerActions = [String: TimerAction]()

    // MARK: Public

    open class var sharedHUD: THUD {
        return Constants.sharedHUD
    }

    public override init () {
        super.init()
        
        let notificationName = UIApplication.willEnterForegroundNotification

        NotificationCenter.default.addObserver(self,
            selector: #selector(THUD.willEnterForeground(_:)),
            name: notificationName,
            object: nil)
        
        userInteractionOnUnderlyingViewsEnabled = false
        container.frameView.autoresizingMask = [ .flexibleLeftMargin,
                                                 .flexibleRightMargin,
                                                 .flexibleTopMargin,
                                                 .flexibleBottomMargin ]

    }

    public convenience init(viewToPresentOn view: UIView) {
        self.init()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    open var dismissBg = true
    open var userInteractionOnUnderlyingViewsEnabled: Bool {
        get {
            return !container.isUserInteractionEnabled
        }
        set {
            container.isUserInteractionEnabled = !newValue
        }
    }

    open var isVisible: Bool {
        return !container.isHidden
    }

    open var contentView: UIView {
        get {
            return container.frameView.content
        }
        set {
            container.frameView.content = newValue
            startAnimatingContentView()
        }
    }

    open var effect: UIVisualEffect? {
        get {
            return container.frameView.effect
        }
        set {
            container.frameView.effect = newValue
        }
    }

    open var leadingMargin: CGFloat = 0

    open var trailingMargin: CGFloat = 0

    open func show(onView view: UIView? = nil) {
        guard let view = view ?? UIApplication.shared.tHudKeyWindow
        else { return }
        if  !view.subviews.contains(container) {
            view.addSubview(container)
            container.frame.origin = CGPoint.zero
            container.frame.size = view.frame.size
            container.autoresizingMask = [ .flexibleHeight, .flexibleWidth ]
            container.isHidden = true
        }
        if dismissBg {
            container.showBackground(animated: true)
        }
        
        showContent()
    }

    func showContent() {
        container.showFrameView()
        startAnimatingContentView()
    }

    open func hide(animated anim: Bool = true, completion: TimerAction? = nil) {

        container.hideFrameView(animated: anim, completion: completion)
        stopAnimatingContentView()
    }

    open func hide(_ animated: Bool, completion: TimerAction? = nil) {
        hide(animated: animated, completion: completion)
    }

    open func hide(afterDelay delay: TimeInterval, completion: TimerAction? = nil) {
        let key = UUID().uuidString
        let userInfo = ["timerActionKey": key]
        if let completion = completion {
            timerActions[key] = completion
        }

        hideTimer?.invalidate()
        hideTimer = Timer.scheduledTimer(timeInterval: delay,
                                                           target: self,
                                                           selector: #selector(THUD.performDelayedHide(_:)),
                                                           userInfo: userInfo,
                                                           repeats: false)
    }

    // MARK: Internal

    @objc internal func willEnterForeground(_ notification: Notification?) {
        self.startAnimatingContentView()
    }

    internal func startAnimatingContentView() {
        if let animatingContentView = contentView as? THUDAnimation, isVisible {
            animatingContentView.startAnimation()
        }
    }

    internal func stopAnimatingContentView() {
        if let animatingContentView = contentView as? THUDAnimation {
            animatingContentView.stopAnimation?()
        }
    }
    
    internal func registerForKeyboardNotifications() {
        container.registerForKeyboardNotifications()
    }
    
    internal func deregisterFromKeyboardNotifications() {
        container.deregisterFromKeyboardNotifications()
    }

    // MARK: Timer callbacks

    @objc internal func performDelayedHide(_ timer: Timer? = nil) {
        let userInfo = timer?.userInfo as? [String: AnyObject]
        let key = userInfo?["timerActionKey"] as? String
        var completion: TimerAction?

        if let key = key, let action = timerActions[key] {
            completion = action
            timerActions[key] = nil
        }

        hide(animated: true, completion: completion)
    }
}

public final class HUD {

    // MARK: Properties
    public static var dimsBackground: Bool {
        get { return THUD.sharedHUD.dismissBg }
        set { THUD.sharedHUD.dismissBg = newValue }
    }

    public static var allowsInteraction: Bool {
        get { return THUD.sharedHUD.userInteractionOnUnderlyingViewsEnabled  }
        set { THUD.sharedHUD.userInteractionOnUnderlyingViewsEnabled = newValue }
    }

    public static var leadingMargin: CGFloat {
        get { return THUD.sharedHUD.leadingMargin  }
        set { THUD.sharedHUD.leadingMargin = newValue }
    }

    public static var trailingMargin: CGFloat {
        get { return THUD.sharedHUD.trailingMargin  }
        set { THUD.sharedHUD.trailingMargin = newValue }
    }

    public static var isVisible: Bool { return THUD.sharedHUD.isVisible }

    // MARK: Public methods, PKHUD based
    public static func show(_ content: THUDType, onView view: UIView? = nil) {
        THUD.sharedHUD.contentView = contentView(content)
        THUD.sharedHUD.show(onView: view)
    }

    public static func hide(_ completion: ((Bool) -> Void)? = nil) {
        THUD.sharedHUD.hide(animated: false, completion: completion)
    }

    public static func hide(animated: Bool, completion: ((Bool) -> Void)? = nil) {
        THUD.sharedHUD.hide(animated: animated, completion: completion)
    }

    public static func hide(afterDelay delay: TimeInterval, completion: ((Bool) -> Void)? = nil) {
        THUD.sharedHUD.hide(afterDelay: delay, completion: completion)
    }

    // MARK: Public methods, HUD based
    public static func flash(_ content: THUDType, onView view: UIView? = nil) {
        HUD.show(content, onView: view)
        HUD.hide(animated: true, completion: nil)
    }

    public static func flash(_ content: THUDType, onView view: UIView? = nil, delay: TimeInterval, completion: ((Bool) -> Void)? = nil) {
        HUD.show(content, onView: view)
        HUD.hide(afterDelay: delay, completion: completion)
    }
    
    // MARK: Keyboard Methods
    public static func registerForKeyboardNotifications() {
        THUD.sharedHUD.registerForKeyboardNotifications()
    }
    
    public static func deregisterFromKeyboardNotifications() {
        THUD.sharedHUD.deregisterFromKeyboardNotifications()
    }

    // MARK: Private methods
    fileprivate static func contentView(_ content: THUDType) -> UIView {
        switch content {
        case .success:
            return THUDSuccessView()
        case .error:
            return THUDErrorView()
        case .progress:
            return THUDLoaderView()

        case let .successWith(title, subtitle):
            return THUDSuccessView(title: title, subtitle: subtitle)
        case let .errorWith(title, subtitle):
            return THUDErrorView(title: title, subtitle: subtitle)
        case let .progressWith(title, subtitle):
            return THUDLoaderView(title: title, subtitle: subtitle)
        }
    }
}

extension UIApplication {
    
    var tHudKeyWindow: UIWindow? {
        // Get connected scenes
        if #available(iOS 13.0, *) {
            return UIApplication.shared.connectedScenes
            // Keep only active scenes, onscreen and visible to the user
                .filter { $0.activationState == .foregroundActive }
            // Keep only the first `UIWindowScene`
                .first(where: { $0 is UIWindowScene })
            // Get its associated windows
                .flatMap({ $0 as? UIWindowScene })?.windows
            // Finally, keep only the key window
                .first(where: \.isKeyWindow)
        } else {
            return UIApplication.shared.windows.filter({$0.isKeyWindow}).first
            // Fallback on earlier versions
        }
    }
    
}
