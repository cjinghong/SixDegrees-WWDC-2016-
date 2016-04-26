//
//  UIColor+JH.swift
//  SixDegrees
//
//  Created by Chan Jing Hong on 16/04/2016.
//  Copyright © 2016 Chan Jing Hong. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {

    public convenience init?(hexString: String, alpha: Float = 1.0) {
        var hexCode = hexString
        if hexCode.hasPrefix("#") {
            hexCode = hexCode.substringFromIndex(hexCode.startIndex.advancedBy(1))
        }

        // Check for valid hex string
        if hexCode.rangeOfString("(^[0-9A-Fa-f]{6}$)|(^[0-9A-Fa-f]{3}$)", options: .RegularExpressionSearch) != nil {
            // Pad short 3 character hex strings
            if hexCode.characters.count == 3 {
                let redHex: String   = hexCode.substringToIndex(hexCode.startIndex.advancedBy(1))
                let greenHex: String = hexCode.substringWithRange(Range(start: hexCode.startIndex.advancedBy(1), end: hexCode.startIndex.advancedBy(2)))
                let blueHex: String  = hexCode.substringFromIndex(hexCode.startIndex.advancedBy(2))

                hexCode = redHex + redHex + greenHex + greenHex + blueHex + blueHex
            }

            let redHex: String   = hexCode.substringToIndex(hexCode.startIndex.advancedBy(2))
            let greenHex: String = hexCode.substringWithRange(Range(start: hexCode.startIndex.advancedBy(2), end: hexCode.startIndex.advancedBy(4)))
            let blueHex: String  = hexCode.substringFromIndex(hexCode.startIndex.advancedBy(4))

            var redInt: CUnsignedInt = 0
            var greenInt: CUnsignedInt = 0
            var blueInt: CUnsignedInt = 0

            NSScanner(string: redHex).scanHexInt(&redInt)
            NSScanner(string: greenHex).scanHexInt(&greenInt)
            NSScanner(string: blueHex).scanHexInt(&blueInt)

            self.init(red: CGFloat(redInt) / 255.0,
                      green: CGFloat(greenInt) / 255.0,
                      blue: CGFloat(blueInt) / 255.0,
                      alpha: 1.0)
        } else {
            return nil
        }
    }

    class func SDGPurple() -> UIColor {
        return UIColor(hexString: "#462066")!
    }
    class func SDGOrange() -> UIColor {
        return UIColor(hexString: "#FFB85F")!
    }
    class func SDGPeach() -> UIColor {
        return UIColor(hexString: "#FF7A5A")!
    }
    class func SDGGreen() -> UIColor {
        return UIColor(hexString: "#00AAA0")!
    }
    class func SDGLightGreen() -> UIColor {
        return UIColor(hexString: "#8ED2C9")!
    }
    class func SDGLightBeige() -> UIColor {
        return UIColor(hexString: "#FCF4D9")!
    }
    class func SDGPink() -> UIColor {
        return UIColor(hexString: "#F59ABE")!
    }
    class func SDGLightBlue() -> UIColor {
        return UIColor(hexString: "#9CDFF6")!
    }
    class func SDGDarkBlue() -> UIColor {
        return UIColor(hexString: "27B9EC")!
    }

    class func randomSDGColor() -> UIColor {
        let number = arc4random_uniform(4)
        switch number {
        case 0:
            return self.SDGOrange()
        case 1:
            return self.SDGPeach()
        case 2:
            return self.SDGGreen()
        case 3:
            return self.SDGPink()
        default:
            return self.SDGPurple()
        }
    }

    class func midColor(colorA: UIColor, colorB: UIColor) -> UIColor? {
        let percent: Double = 0.5 // 50%, middle gradient value between the 2 colors

        let componentsA = colorA.rgb()
        let componentsB = colorB.rgb()

        var resultRed: Double = Double(componentsA?.red ?? 0) + percent * (Double(componentsB?.red ?? 0) - Double(componentsA?.red ?? 0));
        var resultGreen: Double = Double(componentsA?.green ?? 0) + percent * (Double(componentsB?.green ?? 0) - Double(componentsA?.green ?? 0));
        var resultBlue: Double = Double(componentsA?.blue ?? 0) + percent * (Double(componentsB?.blue ?? 0) - Double(componentsA?.blue ?? 0));

        let color: UIColor = UIColor(red: CGFloat(resultRed) / 255.0,
                                     green: CGFloat(resultGreen) / 255.0,
                                     blue: CGFloat(resultBlue) / 255.0,
                                     alpha: 1.0)
        return color
    }

    func rgb() -> (red:Int, green:Int, blue:Int, alpha:Int)? {
        var fRed : CGFloat = 0
        var fGreen : CGFloat = 0
        var fBlue : CGFloat = 0
        var fAlpha: CGFloat = 0
        if self.getRed(&fRed, green: &fGreen, blue: &fBlue, alpha: &fAlpha) {
            let iRed = Int(fRed * 255.0)
            let iGreen = Int(fGreen * 255.0)
            let iBlue = Int(fBlue * 255.0)
            let iAlpha = Int(fAlpha * 255.0)

            return (red:iRed, green:iGreen, blue:iBlue, alpha:iAlpha)
        } else {
            // Could not extract RGBA components:
            return nil
        }
    }
}