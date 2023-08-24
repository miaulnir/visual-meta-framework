import PDFKit

public typealias VisualMetaResponse = (visualMetaSelection: PDFSelection?, bibtex: VisualMetaEntry?, metaEntries: [VisualMetaEntry]?,  headings: [TextHeading]?, glossary: Glossary?, endnotes: Endnotes?, references: References?)

/// VisualMeta Framework
public class VMF {
    
    static public let shared = VMF()
    
    public func parseVisualMeta(in document: PDFDocument, completion: @escaping (VisualMetaResponse?) -> ()) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            
            guard let self = self,
                  let visualMetaSelection = self.visualMetaSelection(from: document),
                  let visualMetaString = visualMetaSelection.string else {
                completion(nil)
                return
            }
            
            var bibtexEntry: VisualMetaEntry?
            var referencesEntries = [String]()
            var glossaryEntries   = [String]()
            var headingsEntries   = [String]()
            
            let entryStrings = visualMetaEntriesString(in: visualMetaString)
            var metaEntries: [VisualMetaEntry] = []
            for entryString in entryStrings {
                if let metaEntry = visualMetaEntry(in: entryString) {
                    metaEntries.append(metaEntry)
                }
            }

            if let selfCitationString = visualMetaString.getString(between: VisualMetaTags.selfCitation) {
                if let metaEntry = self.visualMetaEntry(in: selfCitationString) {
                    if metaEntry.isBibTeX {
                        bibtexEntry = metaEntry
                    }
                }
            }
            
            if let referencesBibTeXString = visualMetaString.getString(between: VisualMetaTags.reference) {
                let referencesBibTeXEntries = bibTeXEntries(in: referencesBibTeXString)
                referencesEntries = referencesBibTeXEntries
            }
            
            if let glossaryBibTeXString = visualMetaString.getString(between: VisualMetaTags.glossary) {
                let glossaryBibTeXEntries = self.bibTeXEntries(in: glossaryBibTeXString)
                glossaryEntries = glossaryBibTeXEntries
            }
            
            if let documentHeadingsBibTeXString = visualMetaString.getString(between: VisualMetaTags.headings) {
                let documentHeadingsBibTeXEntries = self.bibTeXEntries(in: documentHeadingsBibTeXString)
                headingsEntries = documentHeadingsBibTeXEntries
            }
            
            let textHeadings = self.getTextHeadings(documentHeadingsBibTeXEntries: headingsEntries,
                                                    in: document)
            
            let endnotesSelection = self.getEndnotesSelection(in: document,
                                                              and: textHeadings)
            let glossary   = self.getGlossary(from: glossaryEntries)
            let endnotes   = self.getEndnotes(from: endnotesSelection)
            let references = self.getReferences(from: referencesEntries)
            
            let response: VisualMetaResponse = (visualMetaSelection,
                                                bibtexEntry,
                                                metaEntries,
                                                textHeadings,
                                                glossary,
                                                endnotes,
                                                references)
            completion(response)
        }
    }
    
    private func bibTeXEntries(in string: String) -> [String] {
        let correctedString = string.replacingOccurrences(of: "},¶", with: "},¶\n")
            .insertNewlinesBeforeOccurrences(of: "@")
            .replacingOccurrences(of: ", }", with: ",\n}")
        
        var entries: [String] = []
        var currentEntry: String? = nil
        
        correctedString.enumerateLines { line, _ in
            let selectionString = line.trimmingCharacters(in: .whitespacesAndNewlines)
            
            if selectionString.containsWithBibTexInitializer1 {
                currentEntry = line
            } else if selectionString == "}" {
                
                if var entry = currentEntry {
                    entry.append("}")
                    entries.append(entry)
                }
            } else {
                currentEntry?.append(line)
            }
        }
        return entries
    }
    
    private func visualMetaEntriesString(in visualMetaString: String) -> [String] {
        var visualMetaEntries: [String] = []
        let scanner = Scanner(string: visualMetaString)
        
        while !scanner.isAtEnd {
            var string: NSString?
            
            scanner.scanUpTo("@", into: nil)
            scanner.scanUpTo("\n@", into: &string)
            
            if let entry = string {
                let entryString = entry.appending("}")
                visualMetaEntries.append(entryString)
            }
        }
        return visualMetaEntries
    }
    
    public func visualMetaEntry(in visualMetaEntryString: String) -> VisualMetaEntry? {
        
        let repairedEntry = visualMetaEntryString.replacingOccurrences(of: "},", with: "},\n\n")
        
        func _stringTrimming(string: String) -> String {
            let characterSet = CharacterSet(charactersIn: "= {},\"¶")
            return string.trimmingCharacters(in: characterSet)
        }
        
        var kind = ""
        let scanner = Scanner(string: repairedEntry)
        
        var string: NSString?
        scanner.scanUpTo("@", into: nil)
        scanner.scanUpTo("{", into: &string)
        
        if var type = string as String? {
            type.removeFirst(1)
            if type.isEmpty { return nil }
            kind = type
        }
        
        if kind == "headings" {
            var jsonString: NSString?
            scanner.scanUpTo("[", into: nil)
            scanner.scanUpTo("</json>", into: &jsonString)
            if let string = jsonString {
                // Since PDF treats line wraps in this content as newlines, we gotta fix 'em up
                let fixedString = string.replacingOccurrences(of: "\n", with: " ")
                
                return VisualMetaEntry(kind: kind, content: ["json": fixedString], rawValue: visualMetaEntryString)
            }
            return nil
        }
        
        if kind == "glossary" {
            var jsonString: NSString?
            scanner.scanUpTo("[", into: nil)
            scanner.scanUpTo("</json>", into: &jsonString)
            if let string = jsonString {
                // Since PDF treats line wraps in this content as newlines, we gotta fix 'em up
                let fixedString = string.replacingOccurrences(of: "\n", with: " ")
                
                return VisualMetaEntry(kind: kind, content: ["json": fixedString], rawValue: visualMetaEntryString)
            }
            return nil
        }
        
        if kind == "contributing-authors" {
            var jsonString: NSString?
            scanner.scanUpTo("<json>", into: nil)
            scanner.scanUpTo("{", into: nil)
            scanner.scanUpTo("</json>", into: &jsonString)
            if let string = jsonString {
                // Since PDF treats line wraps in this content as newlines, we gotta fix 'em up
                let fixedString = string.replacingOccurrences(of: "\n", with: " ")
                
                return VisualMetaEntry(kind: kind, content: ["json": fixedString], rawValue: visualMetaEntryString)
            }
            return nil
        }
        var entries: [String]
        let entriesStringSkipedTag = repairedEntry.getSuffix(after: "{")
        entries = entriesStringSkipedTag.matches(regex: "([\\s]|[\\n]|,|¶|)[^\\s=\\¶,]+ = \\{[^}]+\\}") ??
        repairedEntry.getSuffix(after: "{")
            .components(separatedBy: "¶")
            .flatMap({$0.components(separatedBy: "\n")})
        
        entries = entries.map{$0.trimmingCharacters(in: .newlines)}
        
        var contentDictionary = [String: Any]()
        
        entries.forEach { entry in
            let keyValueScanner = Scanner(string: entry)
            
            var keyString: NSString?
            keyValueScanner.scanUpTo("=", into: &keyString)
            
            var valueString: NSString?
            keyValueScanner.scanUpTo("\n", into: &valueString)
            
            if let key = keyString, let value = valueString {
                let trimmedKey = _stringTrimming(string: key as String)
                let trimmedValue = _stringTrimming(string: value as String)
                
                contentDictionary[trimmedKey] = trimmedValue
            }
        }
        
        return VisualMetaEntry(kind: kind, content: contentDictionary, rawValue: visualMetaEntryString)
    }
    
    private func visualMetaSelection(from document: PDFDocument) -> PDFSelection? {
        
        var searchSelections: [PDFSelection] = []
        
        var startSelection  : PDFSelection?
        var endSelection    : PDFSelection?
        
        if let selectionForEntireDocument = document.selectionForEntireDocument {
            searchSelections = selectionForEntireDocument.selectionsByLine()
        }
        
        searchSelections.reverse()
        
        for selection in searchSelections {
            if let trimmedString = selection.attributedString?.string.trimmingCharacters(in: .whitespacesAndNewlines) {
                if trimmedString == VisualMetaTags.visualMeta.startTag {
                    startSelection = selection
                } else if trimmedString == VisualMetaTags.visualMeta.endTag {
                    endSelection   = selection
                }
                if startSelection != nil && endSelection != nil {
                    break
                }
            }
        }
        
        guard let start = startSelection,
              let end = endSelection,
              let visualMetaSelection = document.selection(extending: start,
                                                           to: end) else { return nil }
        return visualMetaSelection
    }
    
    private func getTextHeadings(documentHeadingsBibTeXEntries: [String], in document: PDFDocument) -> [TextHeading] {
        guard let documentSelection = document.selectionForEntireDocument else {
            // TODO insert title or filename as first heading
            return []
        }
        var headings = [Heading]()
        for headingEntry in documentHeadingsBibTeXEntries {
            if let metaEntry = visualMetaEntry(in: headingEntry) {
                if let heading = Heading(jsonDict: metaEntry.content) {
                    headings.append(heading)
                }
            }
        }
        let selections = documentSelection.selectionsByLine()
        let headingIndexer = HeadingIndexer(with: selections,
                                            headings: headings)
        return headingIndexer.getTextHeadings()
    }
    
    private func getEndnotesSelection(in document: PDFDocument, and textHeadings: [TextHeading]) -> PDFSelection? {
        var selection: PDFSelection?
        for (index, textHeading) in textHeadings.enumerated() {
            if textHeading.textStyleIdentifier != .heading1 {
                continue
            }
            let lowercasedHeaderName = textHeading.attributedString.string.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            if lowercasedHeaderName.hasPrefix("endnotes") || lowercasedHeaderName.hasSuffix("endnotes") {
                if index == textHeadings.count - 1 {
                    return textHeading.selection
                } else {
                    selection = textHeading.selection
                }
            } else if let existingSelection = selection,
                      let page = existingSelection.pages.first {
                let currentSelectionBounds = existingSelection.bounds(for: page)
                let currentSelectionEndPoint = CGPoint(x: currentSelectionBounds.minX,
                                                       y: currentSelectionBounds.maxY)
                
                let newSelection = textHeading.selection
                if let startPoint = newSelection.startPointOnPage() {
                    return document.selection(from: page,
                                              at: currentSelectionEndPoint,
                                              to: startPoint.page,
                                              at: startPoint.point)
                }
            }
        }
        return nil
    }
    
    private func getGlossary(from glossaryBiBTeXEntrires: [String]) -> Glossary? {
        
        var glossaryEntries: [GlossaryEntry] = []
        for glossaryEntrie in glossaryBiBTeXEntrires {
            if let metaEntry = visualMetaEntry(in: glossaryEntrie),
               let name = metaEntry.content["name"] as? String,
               let description = metaEntry.content["description"] as? String  {
                
                var altNames: [String] = [name]
                
                let keys = metaEntry.content.keys
                
                let filteredKeys = keys.filter { $0.hasPrefix("alt-name") }
                
                for key in filteredKeys {
                    if let value = metaEntry.content[key] as? String {
                        altNames.append(value)
                    }
                }
                
                let glossaryEntry = GlossaryEntry(identifier: UUID().uuidString,
                                                  phrase: name,
                                                  entry: description,
                                                  altNames: altNames)
                
                if let cite = metaEntry.content["cite"] as? String {
                    let citationIdentifiers = cite.components(separatedBy: ", ")
                    glossaryEntry.citationIdentifiers = citationIdentifiers
                }
                
                glossaryEntries.append(glossaryEntry)
            }
        }
        
        if !glossaryEntries.isEmpty {
            return Glossary(with: glossaryEntries)
        }
        
        return nil
    }
    
    private func getEndnotes(from endnotesSelection: PDFSelection?) -> Endnotes? {
        guard let contentSelection = endnotesSelection else { return nil }
        
        let selections = contentSelection.selectionsByLine()
        var endnotesFound: [Endnote] = []
        let newlineAttributedString = NSAttributedString(string: "\n")
        
        var currentEndnote: String?
        var currentAttributedString: NSMutableAttributedString?
        
        for selection in selections {
            guard let attributedString = selection.attributedString,
                  attributedString.length > 0 else { continue }
            var baselineRange: NSRange = NSRange(location: 0, length: 0)
            
            if let baseline = attributedString.attribute(.baselineOffset, at: 0, effectiveRange: &baselineRange) as? Int,
               baseline > 0 {
                
                if let endnoteMarker = currentEndnote,
                   let endnoteAttributedString = currentAttributedString?.trimmed {
                    
                    let endnote = Endnote(identifier: endnoteMarker, content: endnoteAttributedString)
                    endnotesFound.append(endnote)
                    currentEndnote = nil
                    currentAttributedString = nil
                }
                
                let attributedSubstring = attributedString.attributedSubstring(from: baselineRange)
                currentEndnote = attributedSubstring.trimmed.string
                let baselineLength = baselineRange.length
                if attributedString.range.length > baselineRange.length {
                    let subrange = NSRange(location: baselineLength,
                                           length: attributedString.range.length - baselineLength)
                    currentAttributedString = NSMutableAttributedString(attributedString: attributedString.attributedSubstring(from: subrange))
                    currentAttributedString?.append(newlineAttributedString)
                } else {
                    currentAttributedString = NSMutableAttributedString()
                }
            } else {
                if let _ = currentEndnote,
                   Int(attributedString.string) == nil {
                    currentAttributedString?.append(attributedString)
                    currentAttributedString?.append(newlineAttributedString)
                }
            }
        }
        
        if let endnoteMarker = currentEndnote,
           let endnoteAttributedString = currentAttributedString?.trimmed {
            
            let endnote = Endnote(identifier: endnoteMarker, content: endnoteAttributedString)
            endnotesFound.append(endnote)
            currentEndnote = nil
            currentAttributedString = nil
        }
        
        return Endnotes(endnotes: endnotesFound)
    }
    
    private func getReferences(from referenceEntries: [String]) -> References {
        var referenceEntriesDict: [String: ReferenceEntry] = [:]
        
        for (index, reference) in referenceEntries.enumerated() {
            let identifier = "\(index + 1)"
            referenceEntriesDict[identifier] = ReferenceEntry(identifier: identifier,
                                                              content: NSAttributedString(string: reference))
            
            if let citationInfo = BibTeXSupport.citationInfo(for: reference) {
                let citation = LCitation(with: citationInfo)
                
                // Work with page index --
                var pageIndex: Int?
                let pageRange = citation.pageRange
                if !pageRange.isEmpty {
                    if let indexOfDash = pageRange.firstIndex(where: {$0 == "-"}) {
                        pageIndex = Int(citation.pageRange.prefix(upTo: indexOfDash))
                    } else {
                        pageIndex = Int(citation.pageRange)
                    }
                }
                if pageIndex != nil {
                    pageIndex! -= 1
                }
                
                // -----------------------
                
                let urlString = getUrlString(citation: citation)
                if citation.webAddress.count > 0 && !citation.webAddress.contains("play.google.com/books/") {
                    
                    let formattedString = LBibliographyManager.shared.harvardWebReference(for: citation)
                    referenceEntriesDict[identifier] = ReferenceEntry(identifier: identifier,
                                                                      content: NSAttributedString(string: formattedString),
                                                                      filename: citation.filename,
                                                                      title: citation.title,
                                                                      urlString: urlString,
                                                                      quote: citation.quote,
                                                                      pageIndex: pageIndex)
                } else {
                    let formattedString = LBibliographyManager.shared.harvardBookReference(for: citation)
                    referenceEntriesDict[identifier] = ReferenceEntry(identifier: identifier,
                                                                      content: NSAttributedString(string: formattedString),
                                                                      filename: citation.filename,
                                                                      title: citation.title,
                                                                      urlString: urlString,
                                                                      quote: citation.quote,
                                                                      pageIndex: pageIndex)
                }
            }
        }
        return References(with: referenceEntriesDict, labelAttributedString: NSAttributedString())
    }
    
    private func getUrlString(citation: LCitation) -> String? {
        var hasASource = false
        var availableString = ""
        
        let doi = citation.doi.trailingTrim(.whitespacesAndNewlines)
        if !doi.isEmpty {
            availableString = "https://www.doi.org/\(doi)"
            hasASource = true
        } else {
            let webAddress = citation.webAddress.trailingTrim(.whitespacesAndNewlines)
            var hasGooglePlayBook = false
            if webAddress.contains("https://play.google.com/books/") {
                availableString = webAddress
                hasASource = true
                hasGooglePlayBook = true
            }
            if citation.isVideo {
                if availableString.count > 0 {
                    availableString.append(" ")
                }
                availableString.append("[video] ")
            }
            
            if !hasGooglePlayBook {
                if !webAddress.isEmpty {
                    availableString = webAddress
                    hasASource = true
                }
            }
        }
        if !hasASource { return nil }
        return availableString
    }
}
