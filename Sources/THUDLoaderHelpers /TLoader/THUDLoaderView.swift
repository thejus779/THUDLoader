//
//  THUDLoaderView.swift
//  Loader
//
//  Created by Thejus Thejus on 14/12/2021.
//

import Foundation
import UIKit
import QuartzCore

/// PKHUDProgressView provides an indeterminate progress view.
open class THUDLoaderView: THUDBaseView, THUDAnimation {

    public init(title: String? = nil, subtitle: String? = nil) {
        super.init(image: THUDAssets.loaderImage, title: title, subtitle: subtitle)
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    public func startAnimation() {
        imageView.layer.add(THUDLoaderAnimation.discreteRotation, forKey: "loaderAnimation")
    }

    public func stopAnimation() {
    }
}
