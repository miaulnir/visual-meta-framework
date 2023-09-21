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
    
//    public var bibTeXString: String {
//        let start = "@\(kind){\n"
//        let end   = content.map({ "\($0.key) = {\($0.value)},\n" }).joined() + "}"
//        return start
//    }
    
    public init(kind: String, content: [String : Any], rawValue: String) {
        self.kind = kind
        self.content = content
        self.rawValue = rawValue
    }
        
    public mutating func append(by anotherBibTeX: VisualMetaEntry) {
//        guard let index = rawValue.lastIndex(where: {$0 == "}"}) else { return }
        let newKeys = Set(anotherBibTeX.content.keys).subtracting(Set(content.keys))
//        let bibTeXAppend = newKeys.map({ "\($0) = {\(anotherBibTeX.content[$0])},¶\n"}).joined()
//        rawValue.insert(contentsOf: bibTeXAppend, at: index)
        guard !newKeys.isEmpty else { return }
        guard let index = rawValue.lastIndex(where: {$0 == "}"}) else { return }
        rawValue.remove(at: index)
        for key in newKeys {
            if let value = anotherBibTeX.content[key] as? String {
                let element = key + " = {" + value + "},¶\n"
                rawValue.append(contentsOf: element)
            }
            if let value = anotherBibTeX.content[key] as? NSNumber {
                let element = key + " = {\(value)},¶\n"
                rawValue.append(contentsOf: element)
            }
            content[key] = anotherBibTeX.content[key]
        }
        rawValue.append(contentsOf: "}")
    }
}
