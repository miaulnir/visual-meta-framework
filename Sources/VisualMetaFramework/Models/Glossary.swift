
#if os(macOS)
import AppKit
#else
import UIKit
#endif

public struct Glossary {

    public let entries: [GlossaryEntry]
    
    public init(with glossaryEntries: [GlossaryEntry]) {
        self.entries = glossaryEntries
    }
    
    public func glossaryEntry(with phrase: String) -> GlossaryEntry? {
        for entry in entries {
            if entry.lowercasedPhrases.contains(phrase.lowercased()) {
                return entry
            }
        }
        return nil
    }
}

public typealias GlossaryIdentifier = String


public class GlossaryEntry: Codable {
    
    public init(identifier: GlossaryIdentifier, phrase: String, entry: String, altNames: [String] = [], type: String? = nil, urls: [GlossaryURL] = [], citationIdentifiers: [String] = []) {
        self.identifier = identifier
        self.phrase = phrase
        self.altNames = altNames
        self.entry = entry
        self.type = type
        self.urls = urls
    }
    
    let identifier: GlossaryIdentifier
    
    public var phrase: String
    public var altNames: [String] = []
    public var entry: String
    public var type: String?
    
    public var urls: [GlossaryURL] = []
    public var citationIdentifiers: [String] = []
}

public extension GlossaryEntry {
    
    var phraseComponents: [String] {
        var components = [phrase]
        components.append(contentsOf: altNames)
        return components
    }
    
    var lowercasedPhrases: String {
        return phrase.lowercased()
    }
    
    var name: String {
        return phraseComponents.first ?? ""
    }
    
    var alternatives: [String] {
        return Array(phraseComponents.dropFirst())
    }
    
    var attributedString: NSAttributedString {
        let mutableAttributedString = NSMutableAttributedString()
        
        let newEntry = entry.replacingOccurrences(of: "¶", with: "\n")
        
        #if os(macOS)
        mutableAttributedString.append(NSAttributedString(string: name,
                                                          attributes: [.font: NSFont.boldSystemFont(ofSize: NSFont.smallSystemFontSize)]))
        mutableAttributedString.append(NSAttributedString(string: " \(newEntry)",
                                                          attributes: [.font: NSFont.systemFont(ofSize: NSFont.smallSystemFontSize)]))
        #else
        mutableAttributedString.append(NSAttributedString(string: name,
                                                          attributes: [.font: UIFont.boldSystemFont(ofSize: UIFont.smallSystemFontSize)]))
        mutableAttributedString.append(NSAttributedString(string: " \(newEntry)",
                                                          attributes: [.font: UIFont.systemFont(ofSize: UIFont.smallSystemFontSize)]))
        #endif
        return mutableAttributedString
    }
}

extension GlossaryEntry: Equatable {
    
    public static func == (lhs: GlossaryEntry, rhs: GlossaryEntry) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    
}

extension GlossaryEntry: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
    
}

public class GlossaryURL: Codable {
    
    public init(description: String? = nil, url: String) {
        self.description = description
        self.url = url
    }
    
    public var description: String?
    public var url: String
    
}

#if os(macOS)
extension GlossaryEntry {
    
    public var menuItem: NSMenuItem {
        let title = phrase.trimmingCharacters(in: .whitespacesAndNewlines)
        let menuItem = NSMenuItem(title: title, action: nil, keyEquivalent: "")
        menuItem.representedObject = title
        return menuItem
    }
    
}
#endif
