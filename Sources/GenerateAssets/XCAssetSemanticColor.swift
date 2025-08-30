//
//  XCAssetColor.swift
//  xcode-color-assets-generator
//
//  Created by Infinum on 14.05.2024..
//

import Foundation

extension XCAssetSemanticColor {
    struct RGBA {
        let r: String
        let g: String
        let b: String
        let a: String

        init?(hex: String?) {
            guard var hex = hex?.uppercased() else { return nil }
            while hex.hasPrefix("#") {
                hex.removeFirst()
            }
            while hex.count < 8 {
                hex += "F" // Add alpha part
            }
            guard Int(hex, radix: 16) != nil else {
                return nil
            }
            let alpha = Double(Int(hex[slice: 6 ..< 8], radix: 16) ?? 255) / 255.0
            r =  hex[slice: 0 ..< 2]
            g =  hex[slice: 2 ..< 4]
            b =  hex[slice: 4 ..< 6]
            a =  String(format: "%.3f", alpha)
        }
    }
}

struct XCAssetSemanticColor {
    var light: RGBA?
    var dark: RGBA?

    init(lightHex: String, darkHex: String) {
        let lightRgba = XCAssetSemanticColor.RGBA(hex: lightHex)
        let darkRgba = XCAssetSemanticColor.RGBA(hex: darkHex)
        if lightRgba == nil {
            print("Error: Invalid hex! light=\(lightHex)")
        }
        self.light = lightRgba
        self.dark = darkRgba
    }

    var xcassetsContentsJson: String? {
        guard let light = light else { return nil }
        let dark = dark ?? light
        return """
        {
          "colors" : [
            {
              "color" : {
                "color-space" : "srgb",
                "components" : {
                  "alpha" : "\(light.a)",
                  "blue" : "0x\(light.b)",
                  "green" : "0x\(light.g)",
                  "red" : "0x\(light.r)"
                }
              },
              "idiom" : "universal"
            },
            {
              "appearances" : [
                {
                  "appearance" : "luminosity",
                  "value" : "dark"
                }
              ],
              "color" : {
                "color-space" : "srgb",
                "components" : {
                  "alpha" : "\(dark.a)",
                  "blue" : "0x\(dark.b)",
                  "green" : "0x\(dark.g)",
                  "red" : "0x\(dark.r)"
                }
              },
              "idiom" : "universal"
            }
          ],
          "info" : {
            "author" : "xcode",
            "version" : 1
          }
        }
        """
    }

}
