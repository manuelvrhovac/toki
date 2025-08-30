// The Swift Programming Language
// https://docs.swift.org/swift-book
import ArgumentParser
import Foundation

struct Colgen: ParsableCommand {
    @Flag(name: .shortAndLong, help: "Print the current version")
    var versionFlag = false

    @Flag(name: .customShort("l"), help: "List semantic and primitive colors")
    var list

    @Argument(help: "Supported arguments: `generate` to generate colors xcasset.")
    var command: String?

    func run() throws {
        if versionFlag {
            print("Version: \(Self.version)")
            return
        }
        Task {
            try await runAsync()
            Self.exit()
        }
        RunLoop.current.run()
    }

    private func runAsync() async throws {
        switch command {
        case "version", "v":
            print("Version: \(Self.version)")
        case "generate":
            do {
                try await generate()
            } catch {
                print("Couldn't generate. Error: \(error)")
                return
            }
        case .none:
            print("Error: missing command. Use 'generate'.")
        default:
            print("Error: Unsupported command `\(command ?? "")`. Version: \(Self.version).")
        }
    }

    private func generate() async throws {
        guard #available(macOS 13, *) else {
            print("Error: Minimum macOS 13.0 required")
            return
        }

        guard let colgenToken else {
            print("Error: No valid 'COLGEN_TOKEN' found in your zshrc or bash config file!")
            return
        }

        let ymlDict = yamlDictionary()
        if ymlDict.isEmpty {
            print("Error: No valid '.colgen.yml' found in current run path!")
            return
        }

        guard let folderName = ymlDict["projectName"] else {
            print("Error: YML: missing 'projectName' parameter!")
            return
        }

        var storageRepo = ymlDict["storageRepo"] ?? ""
        if storageRepo.isEmpty {
            print("Warning: YML: missing 'storageRepo' parameter. Using fallback: 'infinum/figma-token-storage'.")
            storageRepo = "infinum/figma-token-storage" // TODO: Remove this fallback in future
        }

        var branch = ymlDict["projectName"] ?? ""
        if branch.isEmpty && ymlDict.keys.contains("branch") {
            print("Warning: YML: Parameter 'branch' has been renamed to 'projectName'")
            branch = ymlDict["branch"] ?? "" // TODO: Remove this fallback in future
        }
        if branch.isEmpty {
            print("Error: YML: missing 'storageName' parameter!")
        }

        let jsonString =  try await downloadJsonFromGithub(
            storageRepo: storageRepo,
            branch: branch,
            folderName: folderName,
            token: colgenToken
        )

        if jsonString.isEmpty || jsonString.hasPrefix("404") {
            print("Error: Invalid JSON: '\(jsonString)'. Tip: Your Github COLGEN_TOKEN may have expired.")
            print("Check your .zshrc file and verify it's value! Your COLGEN_TOKEN=\(String(colgenToken.prefix(8)))...")
            return
        }

        guard
            let primitiveKey = ymlDict["primitiveKey"],
            let semanticLightKey = ymlDict["semanticLightKey"],
            let semanticDarkKey = ymlDict["semanticDarkKey"]
        else {
            print("Error: Missing primitiveKey/semanticLightKey/semanticDarkKey in YML file.")
            return
        }

        let shouldGenerateResolvedFiles = ymlDict["shouldGenerateResolvedFiles"].flatMap(Bool.init) ?? false // Optional - defaults to false.
        let useNamespacing = ymlDict["useNamespacing"].flatMap(Bool.init) ?? false // Optional - defaults to false.

        let semanticColors = try FigmaTokensParser.shared.parseFigmaTokens(
            jsonString: jsonString,
            primitiveKey: primitiveKey,
            semanticLightKey: semanticLightKey,
            semanticDarkKey: semanticDarkKey,
            useNamespacing: useNamespacing,
            debugCreateResolved: shouldGenerateResolvedFiles,
            debugListOutput: list == 1 || isRunInXcode
        )
        try XCAssetsColorGenerator.shared.generateXcassets(
            colors: semanticColors,
            outputPath: ymlDict["xcassetsOutputPath"] ?? "GeneratedColors",
            useNamespacing: useNamespacing
        )
    }

    /// Reads the token from ZSHRC or BASH.
    var colgenToken: String? {
        let filenames = [".zshrc", ".bashrc", ".bash_profile"]
        let env = filenames
            .compactMap { try? String(contentsOfFile: NSHomeDirectory() + "/" + $0) }
            .joined(separator: "\n")
        let line = env.components(separatedBy: "\n").first(where: { $0.contains("COLGEN_TOKEN") })
        var token = line?.components(separatedBy: "=").last?.trimmingCharacters(in: .whitespacesAndNewlines)
        if token?.contains("\"") == true {
            print("Error: Token contains quotation marks, please remove them.")
            return nil
        }
        return token
    }

    /// Fetches the JSON file from GitHub repository
    private func downloadJsonFromGithub(
        storageRepo: String?,
        branch: String?,
        folderName: String,
        token: String
    ) async throws -> String {
        guard let storageRepo else {
            print("Error: Missing storage repo.")
            return ""
        }
        guard let branch, !["master", "main"].contains(branch) else {
            print("Error: Missing branch or master/main used as a branch which is not allowed.")
            return ""
        }
        let urlPath = "https://raw.githubusercontent.com/\(storageRepo)/\(branch)/\(folderName)/tokens.json"
        guard let url = URL(string: urlPath) else {
            print("Error: invalid URL: \(urlPath)")
            return ""
        }
        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = ["Authorization": "token \(token)"]
        request.allHTTPHeaderFields = ["Accept": "application/vnd.github.v3.raw"]
        print("Downloading JSON from:", urlPath)
        let (data, _) = try await URLSession.shared.data(for: request)
        let json = String(data: data, encoding: .utf8) ?? ""
        return json
    }

    /// Loads YML file into a dictionary. TODO: Improve parsing.
    private func yamlDictionary() -> [String: String] {
        let path = URL.runPath + "/.colgen.yml"
        guard let yamlString = try? String(contentsOfFile: path, encoding: .utf8) else { return [:] }
        let pairs: [(String, String)] = yamlString.components(separatedBy: "\n").compactMap { line in
            let line = line.components(separatedBy: "#")[0] // Remove comment if any
            let comps = line.components(separatedBy: ": ")
            guard line.count > 3 && comps.count == 2 else { return nil }
            return (comps[0], comps[1].trimmingCharacters(in: .whitespacesAndNewlines))
        }
        return .init(uniqueKeysWithValues: pairs)
    }

    static var version: String {
        #if VERSION
        return VERSION
        #else
        return "dev"
        #endif
    }
}

Colgen.main()
