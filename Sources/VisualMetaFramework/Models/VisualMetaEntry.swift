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
        kind == "article" ||
        kind == "book" ||
        kind == "booklet" ||
        kind == "conference" ||
        kind == "inbook" ||
        kind == "incollection" ||
        kind == "inproceedings" ||
        kind == "manual" ||
        kind == "mastersthesis" ||
        kind == "misc" ||
        kind == "paper" ||
        kind == "phdthesis" ||
        kind == "proceedings" ||
        kind == "techreport" ||
        kind == "unpublished"
    }
    
    public var isHeadingsJSON: Bool { kind == "headings" }
    
    public var isGlossaryJSON: Bool { kind == "glossary" }
    
    public var isContributingAuthors: Bool { kind == "contributing-authors" }
    
    public var isVisualMeta: Bool { kind == "visual-meta" }
    
    public var bibTeXString: String {
        var withoutNewLine = rawValue.replacingOccurrences(of: "\n", with: "")
        var withNewLines   = withoutNewLine.replacingOccurrences(of: "¶", with: "\n")
        var bibTeXString   = withNewLines
        if let lastCommaIndex = withoutNewLine.lastIndex(where: {$0 == ","}) {
            bibTeXString   = String(withNewLines.remove(at: lastCommaIndex))
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
