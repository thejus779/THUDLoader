//
//  THUDSuccessView.swift
//  Loader
//
//  Created by Thejus Thejus on 14/12/2021.
//

import UIKit

/// PKHUDCheckmarkView provides an animated success (checkmark) view.
open class THUDSuccessView: THUDBaseView, THUDAnimation {

    var successLayer: CAShapeLayer = {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 4.0, y: 27.0))
        path.addLine(to: CGPoint(x: 34.0, y: 56.0))
        path.addLine(to: CGPoint(x: 88.0, y: 0.0))

        let layer = CAShapeLayer()
        layer.frame = CGRect(x: 3.0, y: 3.0, width: 88.0, height: 56.0)
        layer.path = path.cgPath

        layer.fillMode    = .forwards
        layer.lineCap     = .round
        layer.lineJoin    = .round

        layer.fillColor   = nil
        layer.strokeColor = UIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1.0).cgColor
        layer.lineWidth   = 6.0
        return layer
    }()

    public init(title: String? = nil, subtitle: String? = nil) {
        super.init(title: title, subtitle: subtitle)
        setup()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        layer.addSublayer(successLayer)
        successLayer.position = layer.position
    }
    open func startAnimation() {}

    open func stopAnimation() {}
}
