//
//  ColorGen.swift
//  xcode-color-assets-generator
//
//  Created by Infinum on 28.03.2024..
//

import Foundation

@available(macOS 13, *)
class XCAssetsColorGenerator {

    static let shared: XCAssetsColorGenerator = .init()
    let fm = FileManager.default

    private init() { /* Singleton init */ }

    /// Takes dctionary of semantic colors and generates XCAssets file. Format of dictionary: `[semanticName: (hex, hex)]`
    ///
    /// Namespacing: Creates folder hierarchy in XCAssets. Colors are hierarched with `.` (dot) in their name.
    /// If you disable namespacing only the last part of color name will be used (e.g. `Signal.Success.success50` -> `success50`).
    /// In this case there must be no duplicated names, otherwise the color will be overwritten!
    func generateXcassets(
        colors: [String: (String, String)],
        outputPath: String,
        useNamespacing: Bool
    ) throws {
        var outputPath = outputPath
        if !outputPath.hasPrefix("/") {
            let rootPath = URL.runPath
            outputPath = rootPath + "/" + outputPath
        }
        if !outputPath.hasSuffix(".xcassets") {
            outputPath += ".xcassets"
        }

        let outputUrl = URL(fileURLWithPath: outputPath)

        try? fm.removeItem(atPath: outputPath)
        try? fm.createDirectory(atPath: outputPath, withIntermediateDirectories: false)

        let assetsUrl = URL(filePath: outputPath)
        let colors = colors.sorted { $0.key < $1.key }

        var duplicates = [String]()
        var invalidNames = [String]()

        /// Write all the semantic colors
        for (colorName, colorPair) in colors {
            let colorName = clean(colorName: colorName)
            let components = colorName.components(separatedBy: ".")
            let colorPath = useNamespacing ? components.joined(separator: "/") : components.last!

            let semanticColor = XCAssetSemanticColor(lightHex: colorPair.0, darkHex: colorPair.1)
            let colorSetUrl = assetsUrl.appending(path: colorPath + ".colorset")
            try fm.createDirectory(at: colorSetUrl, withIntermediateDirectories: true)
            let writePath = colorSetUrl.appending(path: "Contents.json").path()
            if FileManager.default.fileExists(atPath: writePath) {
                duplicates.append(colorPath)
                continue
            }
            guard let json = semanticColor.xcassetsContentsJson else {
                invalidNames.append(colorPath)
                print("Error: Couldn't generate contents JSON for \(colorName) in \(colorPath)")
                continue
            }
            do {
                try json.write(toFile: writePath, atomically: true, encoding: .utf8)
            } catch {
                invalidNames.append(colorPath)
                print("Error: Couldn't write path for '\(colorName)'")
                continue
            }
        }

        guard invalidNames.isEmpty else {
            print("❌ Error: Invalid names / paths. Please fix these in Figma:")
            print(invalidNames.joined(separator: "\n"))
            throw NSError(domain: "colgen", code: 102)
        }

        guard duplicates.isEmpty else {
            print("❌ Error: Duplicates found. Please rename these in Figma or consider using name spacing:")
            print(duplicates.joined(separator: "\n"))
            throw NSError(domain: "colgen", code: 101)
        }

        /// Write the root-path "Contents.json"
        let contentsJson = """
        {
          "info" : {
            "author" : "xcode",
            "version" : 1
          }
        }
        """
        try contentsJson.write(toFile: assetsUrl.appendingPathComponent("Contents.json").path(), atomically: true, encoding: .utf8)

        print("✅ Colgen \(Colgen.version) successfully generated '\(outputUrl.lastPathComponent)'")
        print("📁 \(assetsUrl.deletingLastPathComponent().path)")
    }

    /// Removes or replaces special characters
    private func clean(colorName: String) -> String {
        return colorName
            .replacingOccurrences(of: "&", with: "-and")
            .replacingOccurrences(of: "_", with: "-")
            .replacingOccurrences(of: " ", with: "-")
            .components(separatedBy: .init(charactersIn: "-.").union(.alphanumerics).inverted)
            .joined()
            .lowercased()
    }
}

extension URL {
    static var runPath: String {
        let path = FileManager.default.currentDirectoryPath
        if path.contains("/Xcode/DerivedData") {
            return URL(fileURLWithPath: #file).path.components(separatedBy: "/Sources/")[0]
        }
        return path
    }
}

var isRunInXcode: Bool {
    return FileManager.default.currentDirectoryPath.contains("/Xcode/DerivedData")
}
