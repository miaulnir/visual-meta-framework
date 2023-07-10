import Foundation

public class Endnotes {
    
    internal init(endnotes: [Endnote] = []) {
        var notes: [EndnoteIdentifier: Endnote] = [:]
        for endnote in endnotes {
            notes[endnote.identifier] = endnote
        }
        self.endnotes = notes
    }
    
    
    var endnotes: [EndnoteIdentifier: Endnote] = [:]
    
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
    
    let identifier: EndnoteIdentifier
    let content: NSAttributedString
    
}

extension Endnote: CustomStringConvertible {
    
    public var description: String {
        return "Endnote(identifier: `\(identifier)`, content: `\(content.string.prefix(20))`"
    }
    
}
