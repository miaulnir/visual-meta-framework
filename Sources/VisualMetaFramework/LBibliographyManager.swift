import Foundation

@available(*, deprecated, renamed: "LBibliographyManager")
class LABibliographyManager: LBibliographyManager {}

public class LBibliographyManager {
    
    public static let shared = LBibliographyManager()
    
    fileprivate var harvardDateFormatter: DateFormatter = {
       let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MM yyyy"
        return dateFormatter
    }()

    
    func harvardBookReference(for citation: LCitation) -> String {
        var referenceString = ""
        let shouldSquash = false
        
        let delimeter = ". "
        let commaDelimeter = ", "
        let spaceDelimeter = " "
        let newLine = "\n"
        let hasPageRange = citation.hasPageRange
        
        let hasJournalOrSeries = !citation.series.isEmpty || !citation.journal.isEmpty || !citation.publication.isEmpty
        
        if let title = harvardTitle(for: citation) {
            if title.count > 0 {
                referenceString.append(title)
                if hasJournalOrSeries {
                    referenceString.append(spaceDelimeter)
                } else {
                    referenceString.append(delimeter)
                }
                referenceString.append(newLine)
            }
        } else {
            if let filename = citation.filename,
               filename.count > 0 {
                referenceString.append(filename)
                referenceString.append(delimeter)
                referenceString.append(newLine)
            }
        }
        
        if let author = harvardAuthor(for: citation) {
            if author.count > 0 {
                referenceString.append(author)
//                referenceString.append(newLine)
            }
        }
        
        if let editorString = editor(for: citation) {
            referenceString.append(editorString)
            referenceString.append(delimeter)
        }
        
//        if let journal = harvardJournal(for: citation) {
//            if journal.count > 0 {
//                referenceString.append(journal)
//                if hasJournalOrSeries {
//                    referenceString.append(spaceDelimeter)
//                } else {
//                    referenceString.append(delimeter)
//                }
//            }
//        }
        
        if let year = harvardYear(for: citation) {
            if year.count > 0 {
                referenceString.append(newLine)
                referenceString.append(year)
                referenceString.append(delimeter)
            }
        }
        
//        if let series = harvardSeries(for: citation) {
//            if series.count > 0 {
//                referenceString.append(series)
//                referenceString.append(delimeter)
//            }
//        }

//        if let city = harvardCity(for: citation) {
//            if city.count > 0 {
//                referenceString.append(city)
//                referenceString.append(delimeter)
//            }
//        }

//        if citation.isImage {
//            referenceString.append("[image]")
//            referenceString.append(delimeter)
//        }

//        if let publisher = harvardPublisher(for: citation) {
//            if publisher.count > 0 {
//                referenceString.append(publisher)
//                if hasPageRange && !shouldSquash {
//                    referenceString.append(commaDelimeter)
//                } else {
//                    referenceString.append(delimeter)
//                }
//            }
//        }
        
//        if !shouldSquash {
//            if hasPageRange {
//                let pageRangeString = citation.pageRangeString
//
//                referenceString.append(pageRangeString)
//                referenceString.append(delimeter)
//            }
//        }
        
//        if let isbn = harvardISBN(for: citation) {
//            if isbn.count > 0 {
//                referenceString.append(isbn)
//                referenceString.append(delimeter)
//            }
//        }
        
//        if let filename = citation.filename,
//           filename.count > 0 {
//            referenceString.append(filename)
//            referenceString.append(delimeter)
//        } else {
//            if let availableAt = harvardAvailableAt(for: citation) {
//                if availableAt.count > 0 {
//                    referenceString.append(availableAt)
//                    referenceString.append(delimeter)
//                }
//            }
//        }
        
        return referenceString
    }
    
    func harvardWebReference(for citation: LCitation) -> String {
        var referenceString = ""
        let delimeter = ". "
        let commaDelimeter = ", "
        let spaceDelimeter = " "
        let newLine = "\n"
        
        
        
        let hasJournal = !citation.journal.isEmpty || !citation.publication.isEmpty
        
        if let title = harvardTitle(for: citation) {
            if title.count > 0 {
                referenceString.append(title)
                if hasJournal {
                    referenceString.append(spaceDelimeter)
                } else {
                    referenceString.append(delimeter)
                }
                referenceString.append(newLine)
            }
        } else {
            if let filename = citation.filename,
               filename.count > 0 {
                referenceString.append(filename)
                referenceString.append(delimeter)
                referenceString.append(newLine)
            }
        }
        
        if let author = harvardWebAuthor(for: citation) {
            if author.count > 0 {
                referenceString.append(author)
//                referenceString.append(newLine)
            }
        }
        
//        if let journal = harvardJournal(for: citation) {
//            if journal.count > 0 {
//                referenceString.append(journal)
//                referenceString.append(delimeter)
//            }
//        }
        
        if let year = harvardYear(for: citation) {
            if year.count > 0 {
                referenceString.append(newLine)
                referenceString.append(year)
                referenceString.append(delimeter)
            }
        }
        
//        if citation.isImage {
//            referenceString.append("[image]")
//            referenceString.append(delimeter)
//        }

//        if let city = harvardCity(for: citation) {
//            if city.count > 0 {
//                referenceString.append(city)
//                referenceString.append(delimeter)
//            }
//        }
        
//        if let filename = citation.filename,
//           filename.count > 0 {
//            referenceString.append(filename)
//            referenceString.append(delimeter)
//        } else {
//            if let availableAt = harvardAvailableAt(for: citation) {
//                if availableAt.count > 0 {
//                    referenceString.append(availableAt)
//                    referenceString.append(delimeter)
//                }
//            }
//        }
        
//        if citation.doi.trailingTrim(CharacterSet.whitespacesAndNewlines).isEmpty, let accessedDate = harvardAccessedDate(for: citation) {
//            if accessedDate.count > 0 {
//                referenceString.append(accessedDate)
//                referenceString.append(delimeter)
//            }
//        }
        
        return referenceString
    }
    
    func harvardWebAuthor(for citation: LCitation) -> String? {
        if let author = harvardAuthor(for: citation), !author.isEmpty {
            return author
        } else if let publisher = harvardPublisher(for: citation) {
            return publisher
        } else if let host = harvardHost(for: citation) {
            return host
        }
        
        return nil
    }
    
    func harvardAuthor(for citation: LCitation) -> String? {
        if let author = citation.authorCollection.condensedFormattedAuthorNames, !author.isEmpty {
            return author
        } else if citation.isAnonymous {
            return NSLocalizedString("Anon", comment: "Anonymous author name")
        }
        
        return nil
    }
    
    func harvardYear(for citation: LCitation) -> String? {
        if citation.yearComponent == -1 {
            return nil
        }
        
        
        return "\(citation.yearComponent)"
    }
    
    func editor(for citation: LCitation) -> String? {
        guard !citation.editor.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else  { return nil }
        
        return "In \(citation.editor.trimmingCharacters(in: .whitespacesAndNewlines)) (Eds)"
    }
    
    func harvardAccessedDate(for citation: LCitation) -> String? {
        let accessedString = harvardDateFormatter.string(from: citation.dateAccessed)
        return "[Accessed \(accessedString)]"
    }
    
    func harvardPublisher(for citation: LCitation) -> String? {
        if !citation.publisher.isEmpty {
            return citation.publisher
        }
        
        return nil
    }
    
    func harvardISBN(for citation: LCitation) -> String? {
        if !citation.isbn.isEmpty {
            return "ISBN: \(citation.isbn)"
        }
        
        return nil
    }
    
    func harvardHost(for citation: LCitation) -> String? {
        guard let url = URL(string: citation.webAddress),
            let host = url.host else { return nil }
        return host
    }
    
    func harvardAvailableAt(for citation: LCitation) -> String? {
//        var linkAttributes = modifiedStyle.attributes
//        linkAttributes.removeValue(forKey: NSAttributedString.Key.underlineStyle)
        var hasASource = false
        var availableString = ""
        
        let doi = citation.doi.trailingTrim(CharacterSet.whitespacesAndNewlines)
        if !doi.isEmpty {
            
            availableString.append("\nDOI: ")
            availableString.append("https://www.doi.org/\(doi)")
            hasASource = true
        } else {
            
            let webAddress = citation.webAddress.trailingTrim(CharacterSet.whitespacesAndNewlines)
            
            var hasGooglePlayBook = false
            
            if webAddress.contains("play.google.com/books/") {
                let webAddressString = "\nFrom: \(webAddress)"
            
                availableString.append(webAddressString)
                hasASource = true
                hasGooglePlayBook = true
            }
            
            
            
                        if citation.isVideo {
                if availableString.count > 0 {
                    availableString.append(" ")
                }
                
                availableString.append("[video] ")
            }
            
            var hasAddedAvailableFrom = false
            if !hasGooglePlayBook {
                let webAddress = citation.webAddress.trailingTrim(CharacterSet.whitespacesAndNewlines)
                if !webAddress.isEmpty {
                    
                    if !hasAddedAvailableFrom {
                        availableString.append("\nFrom ")
                        hasAddedAvailableFrom = true
                    }
                    
                    availableString.append(webAddress)
                    hasASource = true
                }
            }

        }

        if !hasASource { return nil }
        
        return availableString
    }
    
    func harvardTitle(for citation: LCitation) -> String? {
        let title = citation.title
        if title.count > 0 {
            return title
        }
        
        return nil
    }
    
    func harvardJournal(for citation: LCitation) -> String? {
        if citation.journal.count > 0 {
            return citation.journal
        } else if citation.publication.count > 0 {
            return citation.publication
        }
        
        return nil
    }
    
    func harvardSeries(for citation: LCitation) -> String? {
        let series = citation.series
        if series.count > 0 {
            return series
        }
        
        return nil
    }
    
    func harvardCity(for citation: LCitation) -> String? {
        let location = citation.location
        if location.count > 0 {
            return location
        }
        
        return nil
    }
}

