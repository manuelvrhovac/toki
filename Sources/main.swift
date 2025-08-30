// The Swift Programming Language
// https://docs.swift.org/swift-book
import ArgumentParser
import Foundation

struct Toki: ParsableCommand {
    @Flag(name: .customShort("l"), help: "List semantic and primitive colors")
    var list

    @Argument(help: "Supported arguments: `generate` to generate colors xcasset.")
    var command: String?

    func run() throws {
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

        guard let tokiToken else {
            print("Error: No valid 'COLGEN_TOKEN' found in your zshrc or bash config file!")
            return
        }

        print("Toki is only a stub for now! Version: '\(Self.version)'")

        // TODO: WIP
    }

    /// Reads the token from ZSHRC or BASH.
    var tokiToken: String? {
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

    static var version: String {
        #if VERSION
        return VERSION
        #else
        return "dev"
        #endif
    }
}

Toki.main()
