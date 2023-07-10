//
//  File.swift
//  
//
//  Created by Igor on 23.05.2023.
//

import Foundation

/// Object after "@{"
public struct VisualMetaEntry {
    
    let kind    : String
    let content : [String: Any]
    let rawValue: String
    
    var isBibTeX: Bool {
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
    
    var isHeadingsJSON: Bool { kind == "headings" }
    
    var isGlossaryJSON: Bool { kind == "glossary" }
    
    var isContributingAuthors: Bool { kind == "contributing-authors" }
    
    var isVisualMeta: Bool { kind == "visual-meta" }
    
}
