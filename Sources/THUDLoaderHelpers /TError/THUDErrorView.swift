//
//  THUDErrorView.swift
//  Loader
//
//  Created by Thejus Thejus on 14/12/2021.
//

import UIKit

/// THUDErrorView provides an animated error (cross) view.
open class THUDErrorView: THUDBaseView, THUDAnimation {

    var line1 = THUDErrorView.line()
    var line2 = THUDErrorView.line()

    // Draw line
    class func line() -> CAShapeLayer {
        let line = CAShapeLayer()
        line.frame = CGRect(x: 0, y: 0, width: 90, height: 90)
        line.path = {
            let path = UIBezierPath()
            path.move(to: CGPoint(x: 0, y: 45))
            path.addLine(to: CGPoint(x: 90, y: 45))
            return path.cgPath
        }()

        line.lineCap     = .round
        line.lineJoin    = .round
        line.fillMode    = .forwards

        line.fillColor   = nil
        line.strokeColor = UIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1.0).cgColor
        line.lineWidth   = 6
        return line
    }

    public init(title: String? = nil, subtitle: String? = nil) {
        super.init(title: title, subtitle: subtitle)
        setup()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    func setup() {
        layer.addSublayer(line1)
        layer.addSublayer(line2)
        line1.position = layer.position
        line2.position = layer.position
    }
    public func startAnimation() {
        // Implement any animation if needed
        // User the 2 lines to form a cross at 45 Degrees (-45 * Pi / 180)
        line1.transform = CATransform3DMakeRotation(-CGFloat(.pi / 4.0), 0.0, 0.0, 1.0)
        line2.transform = CATransform3DMakeRotation(CGFloat(.pi / 4.0), 0.0, 0.0, 1.0)
    }

    public func stopAnimation() {
        // Stop the implemented animation here
    }
}
