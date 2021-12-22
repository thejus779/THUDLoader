//
//  THUDBaseView.swift
//  Loader
//
//  Created by Thejus Thejus on 14/12/2021.
//

import UIKit

/// PKHUDSquareBaseView provides a square view, which you can subclass and add additional views to.
open class THUDBaseView: UIView {

    static let defaultSquareBaseViewFrame = CGRect(origin: CGPoint.zero, size: CGSize(width: 156.0, height: 156.0))

    public override init(frame: CGRect) {
        super.init(frame: frame)
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    public init(image: UIImage? = nil, title: String? = nil, subtitle: String? = nil) {
        super.init(frame: THUDBaseView.defaultSquareBaseViewFrame)
        self.imageView.image = image
        titleLabel.text = title
        subtitleLabel.text = subtitle

        addSubview(imageView)
        addSubview(titleLabel)
        addSubview(subtitleLabel)
    }

    public let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.alpha = 0.85
        imageView.clipsToBounds = true
        imageView.contentMode = .center
        return imageView
    }()

    public let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 17.0)
        label.textColor = UIColor.black.withAlphaComponent(0.85)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.25
        return label
    }()

    public let subtitleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 14.0)
        label.textColor = UIColor.black.withAlphaComponent(0.7)
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 2
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.25
        return label
    }()

    open override func layoutSubviews() {
        super.layoutSubviews()

        let margin: CGFloat = THUD.sharedHUD.leadingMargin + THUD.sharedHUD.trailingMargin
        let originX: CGFloat = margin > 0 ? margin : 0.0
        let safeWidth = bounds.size.width - 2 * margin
        let height = bounds.size.height

        let halfHeight = CGFloat(ceilf(CFloat(height / 2.0)))
        let quarterHeight = CGFloat(ceilf(CFloat(height / 4.0)))
        let threeQuarterHeight = CGFloat(ceilf(CFloat(height / 4.0 * 3.0)))

        titleLabel.frame = CGRect(origin: CGPoint(x: originX, y: 0.0), size: CGSize(width: safeWidth, height: quarterHeight))
        imageView.frame = CGRect(origin: CGPoint(x: originX, y: quarterHeight), size: CGSize(width: safeWidth, height: halfHeight))
        subtitleLabel.frame = CGRect(origin: CGPoint(x: originX, y: threeQuarterHeight), size: CGSize(width: safeWidth, height: quarterHeight))

    }
}
