//
//  TLoader.swift
//  Loader
//
//  Created by Thejus Thejus on 14/12/2021.
//

import UIKit

open class THUDAssets: NSObject {
    open class var loaderImage: UIImage { return THUDAssets.bundledImage(named: "loader") }
    
    internal class func bundledImage(named name: String) -> UIImage {
        let primaryBundle = Bundle(for: THUDAssets.self)
        if let image = UIImage(named: name, in: primaryBundle, compatibleWith: nil) {
            return image
        }
        return UIImage()
    }
}
