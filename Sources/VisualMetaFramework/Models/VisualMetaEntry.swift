//
//  File.swift
//  
//
//  Created by Igor on 23.05.2023.
//

import Foundation

/// Object after "@{"
public struct VisualMetaEntry {
    
    public let kind    : String
    public var content : [String: Any]
    public var rawValue: String
    
    public var isBibTeX: Bool {
        return BibTeXSupport.EntryType.allCases.map({$0.rawValue}).contains(kind)
    }
    
    public var isHeadingsJSON: Bool { kind == "headings" }
    
    public var isGlossaryJSON: Bool { kind == "glossary" }
    
    public var isContributingAuthors: Bool { kind == "contributing-authors" }
    
    public var isVisualMeta: Bool { kind == "visual-meta" }
    
    public var bibTeXString: String {
        var bibTeXString = rawValue.replacingOccurrences(of: "\n", with: "")
            .replacingOccurrences(of: "¶ ", with: "\n")
            .replacingOccurrences(of: "¶", with: "\n")
        if let lastCommaIndex = bibTeXString.lastIndex(where: {$0 == ","}) {
            bibTeXString.remove(at: lastCommaIndex)
        }
        return bibTeXString
    }
    
    public init(kind: String, content: [String : Any], rawValue: String) {
        self.kind = kind
        self.content = content
        self.rawValue = rawValue
    }
    
    public func isDifferentBibTeX(by anotherBibTeX: VisualMetaEntry) -> Bool {
        return !Set(anotherBibTeX.content.keys).subtracting(Set(content.keys)).isEmpty
    }
        
    public func appended(by anotherBibTeX: VisualMetaEntry) -> VisualMetaEntry? {
        let newKeys = Set(anotherBibTeX.content.keys).subtracting(Set(content.keys))
       
        guard !newKeys.isEmpty else { return self }
        var newRawValue = rawValue
        var newContent  = content
        let kind        = kind

        if let index = newRawValue.lastIndex(where: {$0 == "}"}) {
            newRawValue.remove(at: index)
        }
        
        for key in newKeys {
            if let value = anotherBibTeX.content[key] as? String {
                let element = key + " = {" + value + "},¶\n"
                newRawValue.append(contentsOf: element)
            }
            if let value = anotherBibTeX.content[key] as? NSNumber {
                let element = key + " = {\(value)},¶\n"
                newRawValue.append(contentsOf: element)
            }
            newContent[key] = anotherBibTeX.content[key]
        }
        newRawValue.append(contentsOf: "}")
        
        return VisualMetaEntry(kind: kind, content: newContent, rawValue: newRawValue)
    }
}
