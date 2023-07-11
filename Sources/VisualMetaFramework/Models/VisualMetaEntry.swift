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
    public let content : [String: Any]
    public let rawValue: String
    
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
    
    public init(kind: String, content: [String : Any], rawValue: String) {
        self.kind = kind
        self.content = content
        self.rawValue = rawValue
    }
}
