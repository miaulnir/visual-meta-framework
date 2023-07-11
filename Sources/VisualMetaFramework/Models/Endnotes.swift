import Foundation

public class Endnotes {
    
    public init(endnotes: [Endnote] = []) {
        var notes: [EndnoteIdentifier: Endnote] = [:]
        for endnote in endnotes {
            notes[endnote.identifier] = endnote
        }
        self.endnotes = notes
    }
    
    
    public var endnotes: [EndnoteIdentifier: Endnote] = [:]
    
}

public extension Endnotes {
    
    func add(_ endnote: Endnote) {
        endnotes[endnote.identifier] = endnote
    }
    
    func remove(_ endnote: Endnote) {
        endnotes.removeValue(forKey: endnote.identifier)
    }
    
    func endnote(with identifier: EndnoteIdentifier) -> Endnote? {
        return endnotes[identifier]
    }
    
    func containsEndnoteWithIdentifier(_ identifier: EndnoteIdentifier) -> Bool {
        return endnote(with: identifier) != nil
    }
}

public typealias EndnoteIdentifier = String

public struct Endnote {
    
    public let identifier: EndnoteIdentifier
    public let content: NSAttributedString
    
    public init(identifier: EndnoteIdentifier, content: NSAttributedString) {
        self.identifier = identifier
        self.content = content
    }
    
}

extension Endnote: CustomStringConvertible {
    
    public var description: String {
        return "Endnote(identifier: `\(identifier)`, content: `\(content.string.prefix(20))`"
    }
    
}
