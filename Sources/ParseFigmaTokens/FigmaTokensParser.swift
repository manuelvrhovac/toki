//
//  FigmaTokensParser.swift
//  xcode-color-assets-generator
//
//  Created by Infinum on 14.05.2024..
//

import Foundation

/// Parser that parses the JSONs obtained via the "Design Tokens Manager" Figma plugin.
@available(macOS 13, *)
class FigmaTokensParser {
    static let shared: FigmaTokensParser = .init()

    let fm = FileManager.default
    let decoder = JSONDecoder()

    func parseFigmaTokens(
        jsonString: String,
        primitiveKey: String,
        semanticLightKey: String,
        semanticDarkKey: String,
        useNamespacing: Bool,
        debugCreateResolved: Bool,
        debugListOutput: Bool
    ) throws -> [String: (String, String)] {
        let object = try JSONSerialization.jsonObject(with: jsonString.data(using: .utf8) ?? Data(), options: [])
        let lightColors = parseRawColors(jsonObject: object, parentName: semanticLightKey)
        let darkColors = parseRawColors(jsonObject: object, parentName: semanticDarkKey)
        let primitiveColors = parseRawColors(jsonObject: object, parentName: primitiveKey)

        let allSemanticKeys = lightColors.keys.sorted()

        let dictionaryRaw: [String: (RawColor, RawColor)] = Dictionary(uniqueKeysWithValues: allSemanticKeys.compactMap { key in
            guard let rawLight = lightColors[key] else {
                print("Error: Invalid Token: \(key). Must have light reference to primitive color.")
                return nil
            }
            let rawDark = darkColors[key] ?? rawLight // Dark may fallback to light value.
            return (key, (rawLight, rawDark))
        })

        let dictionaryHex: [String: (String, String)] = dictionaryRaw.mapValues { rawLight, rawDark in
            guard let lightColorValue = primitiveColors[rawLight.value]?.value else {
                return ("", "")
            }
            let darkColorValue = primitiveColors[rawDark.value]?.value ?? lightColorValue // Dark may fallback to light value.
            return (lightColorValue, darkColorValue)
        }

        if debugCreateResolved || debugListOutput {
            let trim: (String) -> String = { useNamespacing ? $0 : $0.components(separatedBy: ".").last! }

            let pad1 = primitiveColors.map(\.key).map(trim).map(\.count).max() ?? 0 // Add padding for nicer output
            let pad2 = dictionaryRaw.map { trim($0.key).count }.max() ?? 0 // Add padding for nicer output
            let pad3 = dictionaryRaw.map { trim($0.value.0.value).count }.max() ?? 0 // Add padding for nicer output

            let primitives = primitiveColors.map { trim($0).pad(pad1+2) + $1.value.pad(60) }.joined(separator: "\n")
            let semanticRaw = dictionaryRaw.sorted.map { trim($0).pad(pad2+2) + trim($1.0.value).pad(pad3+2) + trim($1.1.value).pad(60) }.joined(separator: "\n")
            let semanticHex = dictionaryHex.sorted.map { trim($0).pad(pad2+2) + $1.0.pad(16) + $1.1.pad(16) }.joined(separator: "\n")

            if debugCreateResolved {
                try? primitives.write(toFile: URL.runPath + "/.colgen.primitive.resolved", atomically: true, encoding: .utf8)
                try? semanticRaw.write(toFile: URL.runPath + "/.colgen.semantic.resolved", atomically: true, encoding: .utf8)
                try? semanticHex.write(toFile: URL.runPath + "/.colgen.semantic.hex.resolved", atomically: true, encoding: .utf8)
            }

            if debugListOutput {
                print("\n--- Primitive Colors: [Name / HEX] --------------------------------------------------------------------------\n" + primitives)
                print("\n--- Semantic Colors: [Name / Light / Dark] ------------------------------------------------------------------\n" + semanticRaw)
                print("\n--- Semantic Colors: [Name / LightHEX / DarkHEX] ------------------------------------------------------------\n" + semanticHex)
            }
        }

        print("🎨 Found \(lightColors.count) semantic and \(primitiveColors.count) primitive colors!")

        return dictionaryHex
    }

    func parseRawColors(jsonObject: Any, parentName: String) -> [String: RawColor] {
        guard let mainDict = jsonObject as? [String: Any] else { return [:] }
        guard let dict = mainDict[parentName] as? [String: Any] else { return [:] }
        let rawColors = parseRawColors(dict: dict, folder: "")
            .filter { !$0.name.hasPrefix("Dimensions.") } // Filter out Figma Dimensions.
        return .init(uniqueKeysWithValues: zip(rawColors.map(\.name), rawColors))
    }

    func parseRawColors(dict: [String: Any]?, folder: String) -> [RawColor] {
        guard let dict else { return [] }
        var colors: [RawColor] = []
        for (key, value) in dict {
            let key = folder.isEmpty ? key : folder + "." + key
            if let subdict = value as? [String: String] {
                colors.append(.init(key: key, dict: subdict))
            } else if let subdict = value as? [String: [String: Any]] {
                colors += parseRawColors(dict: subdict, folder: key)
            }
        }
        return colors
    }

    struct RawColor {
        let name: String
        let value: String

        init(key: String, dict: [String: String]) {
            let parent = dict["parent"] ?? ""
            self.name = key.removingPrefix(parent + ".")
            self.value = dict["value"]?.withoutBrackets ?? ""
        }
    }
}

// MARK: - Helper Methods

private extension Dictionary where Key == String {
    var sorted: [(String, Value)] {
        return self.sorted { $0.0 < $1.0 }
    }

    subscript(_ key: String?) -> Value? {
        guard let key else { return nil }
        return self[key]
    }
}

extension String {
    // Debug purposes
    var ns: NSString { self as NSString }

    subscript(slice slice: Range<Int>) -> String {
        let chars = map { $0 }
        return String(chars[slice])
    }

    var withoutBrackets: String {
        trimmingCharacters(in: .init(charactersIn: "{}"))
    }

    func removingPrefix(_ prefix: String) -> String {
        if hasPrefix(prefix) {
            var new = self
            new.removeFirst(prefix.count)
            return new
        } else {
            return self
        }
    }

    // Debug purposes
    func pad(_ length: Int) -> String {
        self
            .removingPrefix("Color.")
            .padding(toLength: length, withPad: " ", startingAt: 0)
    }
}
