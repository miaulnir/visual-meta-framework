#if os(macOS)
import AppKit
#else
import UIKit
#endif

//fileprivate let harvardDateFormatter: DateFormatter = {
//    let dateFormatter = DateFormatter()
//    dateFormatter.dateFormat = "dd MM yyyy"
//    return dateFormatter
//}()

@available(*, deprecated, renamed: "LCitation")
public class LACitation: LCitation {}

public class LCitation: NSObject, NSCopying { // LACitation
    
    enum LCitationFormat: String {

        case quoteMarks = "quotesNoName"
        case quotesWithNameAndYear = "quoteWithName"
        
        case italicText = "paraphrased"
        case italicTextWithNameAndYear = "quote"
        
        case textWithNameAndYear = "invisible"
        case textWithYear = "date"
        
        case blockQuote = "paragraphQuote"
        case blockQuoteWithName = "paragraphQuoteWithName"

        case nameAndDate = "nameAndDate"                                // N/A - No UI
        
        case attachment = "attachment"                                  // N/A - No UI
        
        static public func build(rawValue:String) -> LCitationFormat {
            return LCitationFormat(rawValue: rawValue) ?? .quoteMarks
        }
    }
    
    enum LCitationPreviewDestination {
        case author
        case browser
    }
    
    @objc public var identifier = UUID().uuidString
    
    @objc public dynamic var title = ""
    @objc public dynamic var filename: String?
    @objc public dynamic var author: String?
    @objc public dynamic var authors: [String] = []
    @objc public dynamic var citationAuthors: [CitationAuthor] = []
    @objc public dynamic var authorInfo: NSAttributedString = NSAttributedString()
    @objc public dynamic var youTubePlaybackHour: Int = 0
    @objc public dynamic var youTubePlaybackMinute: Int = 0
    @objc public dynamic var youTubePlaybackSecond: Int = 0
    @objc public dynamic var date: Date?
    @objc public dynamic var dateAccessed = Date()
    @objc public dynamic var webAddress = ""
    @objc public dynamic var source = ""
    
    @objc public dynamic var dayComponent: Int = -1
    @objc public dynamic var monthComponent: Int = -1
    @objc public dynamic var yearComponent: Int = -1
    
    @objc public dynamic var note = ""
    @objc public dynamic var quote = ""
    @objc public dynamic var originalText = ""
    
    @objc public dynamic var location = ""
    @objc public dynamic var publisher = ""
    @objc public dynamic var publication = ""
    @objc public dynamic var issue = ""
    @objc public dynamic var isbn = ""
    @objc public dynamic var asin = ""
    @objc public dynamic var doi = ""
    @objc public dynamic var issn = ""
    @objc public dynamic var pubMed = ""
    @objc public dynamic var arXiv = ""
    @objc public dynamic var volume = ""
    
    @objc public dynamic var series = ""
    
    @objc public dynamic var editor = ""
    @objc public dynamic var journal = ""
    
    @objc public dynamic var pageRangeStart: Int = -1
    @objc public dynamic var pageRangeEnd: Int = -1
    
    @objc public dynamic var pageRange: String = ""
    
    @objc public dynamic var creationSource: String = "manual"
    
    @objc public dynamic var bibTeXType: String = "misc"
    
    @objc public dynamic var hasSaved: Bool = false
    
    @objc public dynamic var isImage: Bool = false
    
    @objc public dynamic var isAnonymous: Bool = false
    
    
    
    
    //title contains $value || authorNamesForSearch contains $value || webAddress contains $value || note contains $value || quote contains $value || originalText contains $value || location contains $value || publisher contains $value || publication contains $value || issue contains $value || isbn contains $value || asin contains $value || doi contains $value || issn contains $value || pubMed contains $value || arXiv contains $value || volume  contains $value || series contains $value || editor contains $value || journal contains
    
    
    
    
    @objc public var authorCollection: CitationAuthorCollection {
        let citationAuthorCollection = CitationAuthorCollection()
        citationAuthorCollection.authors = citationAuthors
//        for author in authors {
//            let citationAuthor = CitationAuthor(with: author)
//            citationAuthorCollection.authors.append(citationAuthor)
//        }
//
        return citationAuthorCollection
    }
    
    public var averageRating: Double?
    public var ratingCount: Int?
    
    
    @objc public dynamic var displayString: String? {
        
        if !title.isEmpty, let authorNames = authorCollection.fullLocalizedNames, !authorNames.isEmpty {
            return "\(title) by \(authorNames)"
        } else if !title.isEmpty {
            return title
        } else if !doi.isEmpty {
            return doi
        } else if let url = webURL {
            return url.absoluteString
        }
        
        
        return nil
    }
    
    var bibTeXID: String {
        if !doi.isEmpty {
            return doi
        } else {
            var trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines).trimmingCharacters(in: .punctuationCharacters)
            trimmedTitle = trimmedTitle.replacingOccurrences(of: " ", with: "")
            
            if trimmedTitle.count > 10 {
                trimmedTitle = (trimmedTitle as NSString).substring(to: 10)
            }
            
            if let authorNames = authorCollection.namesForCitationIdentifier {
                
                if !trimmedTitle.isEmpty {
                    return "\(authorNames)/\(trimmedTitle)"
                } else {
                    return authorNames
                }
            } else if !trimmedTitle.isEmpty {
                return trimmedTitle
            }
        }
        
        return identifier
    }
    
    @objc public dynamic var authorNamesForSearch: String {
        guard let authorNames = authorCollection.fullLocalizedNames else { return "" }
        
        return authorNames
    }
    
    @objc public var hasSubscript: Bool = false
    
    @objc public var industryIdentifiers = [[String : Any]]()
    
    @objc public var youtubeStartTimeDateComponents: DateComponents? {
        if (youTubePlaybackHour > 0) || (youTubePlaybackMinute > 0) || (youTubePlaybackSecond > 0) {
            var dateComponents = DateComponents()
            if youTubePlaybackHour > 0 {
                dateComponents.hour = youTubePlaybackHour
            }
            
            if youTubePlaybackMinute > 0 {
                dateComponents.minute = youTubePlaybackMinute
            }
            
            if youTubePlaybackSecond > 0 {
                dateComponents.second = youTubePlaybackSecond
            }
            
            return dateComponents
        }
        return nil
    }
    
    public func plist() -> [String : Any] {
        var plist = [String : Any]()

        plist["identifier"] = identifier
        plist["title"]      = title
        plist["filename"]   = filename
        plist["author"]     = author
        plist["authors"]    = authors
        
        var citationAuthorsPlist = [[String : Any]]()
        
        for citationAuthor in citationAuthors {
            citationAuthorsPlist.append(citationAuthor.plist())
        }
        
        plist["citationAuthors"] = citationAuthorsPlist
        #if os(macOS)
        if let data = authorInfo.rtf(from: NSRange(location: 0, length: authorInfo.length), documentAttributes: [:]) {
            plist["authorInfo"] = data
        }
        #else
        if let data = try? authorInfo.rtf() {
            plist["authorInfo"] = data
        }
        #endif
        
        
        plist["youTubePlaybackHour"] = youTubePlaybackHour
        plist["youTubePlaybackMinute"] = youTubePlaybackMinute
        plist["youTubePlaybackSecond"] = youTubePlaybackSecond
        plist["date"] = date
        plist["dateAccessed"] = dateAccessed
        plist["webAddress"] = webAddress
        plist["source"] = source
        
        plist["dayComponent"] = dayComponent
        plist["yearComponent"] = yearComponent
        plist["monthComponent"] = monthComponent
        
        plist["note"] = note
        plist["quote"] = quote
        plist["originalText"] = originalText
        
        plist["location"] = location
        plist["publisher"] = publisher
        plist["publication"] = publication
        plist["issue"] = issue
        plist["isbn"] = isbn
        plist["asin"] = asin
        plist["doi"] = doi
        plist["issn"] = issn
        plist["pubMed"] = pubMed
        plist["arXiv"] = arXiv
        plist["volume"] = volume
        
        plist["series"] = series
        
        plist["editor"] = editor
        plist["journal"] = journal
        
        plist["creationSource"] = creationSource
        
        plist["bibTeXType"] = bibTeXType
        
        plist["pageRangeStart"] = pageRangeStart
        plist["pageRangeEnd"] = pageRangeEnd
        
        plist["pageRange"] = pageRange
        
        plist["hasSaved"] = hasSaved
        
        plist["isAnonymous"] = isAnonymous
        
        plist["averageRating"] = averageRating
        plist["ratingCount"] = ratingCount
        
        plist["industryIdentifiers"] = industryIdentifiers
        
        return plist
    }
    
    
    public func copy(with zone: NSZone? = nil) -> Any {
        let copy = LCitation()
        
        copy.identifier      = identifier
        copy.title           = title
        copy.filename        = filename
        copy.author          = author
        copy.authors         = authors
        copy.authorInfo      = authorInfo
        copy.citationAuthors = citationAuthors
        
        copy.youTubePlaybackHour   = youTubePlaybackHour
        copy.youTubePlaybackMinute = youTubePlaybackMinute
        copy.youTubePlaybackSecond = youTubePlaybackSecond
        copy.date                  = date
        copy.dateAccessed          = dateAccessed
        copy.webAddress            = webAddress
        copy.source                = source
        
        copy.dayComponent   = dayComponent
        copy.yearComponent  = yearComponent
        copy.monthComponent = monthComponent
        
        copy.note         = note
        copy.quote        = quote
        copy.originalText = originalText
        
        copy.location    = location
        copy.publisher   = publisher
        copy.publication = publication
        copy.issue       = issue
        copy.isbn        = isbn
        copy.asin        = asin
        copy.doi         = doi
        copy.issn        = issn
        copy.pubMed      = pubMed
        copy.arXiv       = arXiv
        copy.volume      = volume
        
        copy.series = series
        
        copy.editor  = editor
        copy.journal = journal
        
        copy.creationSource = creationSource
        
        copy.bibTeXType = bibTeXType
        
        copy.pageRangeStart = pageRangeStart
        copy.pageRangeEnd   = pageRangeEnd
        
        copy.pageRange = pageRange
        
        copy.hasSaved = hasSaved
        
        copy.isAnonymous = isAnonymous
        
        copy.averageRating = averageRating
        copy.ratingCount   = ratingCount
        
        copy.industryIdentifiers = industryIdentifiers
        
        return copy
    }
    
    public init(with plist: [String: Any]) {
        creationSource = LCitation.string(for: "creationSource", in: plist)
        
        identifier = LCitation.string(for: "identifier", in: plist)
        title = LCitation.string(for: "title", in: plist)
        filename = LCitation.string(for: "filename", in: plist)
        author = plist["author"] as? String
        
        if let authorsArray = plist["authors"] as? [String] {
            authors = authorsArray
        } else {
            authors = []
        }
        
        var plistCitationAuthors = [CitationAuthor]()
        if let citationAuthorsArray = plist["citationAuthors"] as? [[String : Any]], citationAuthorsArray.count > 0 {
            for citationAuthorPlist in citationAuthorsArray {
                plistCitationAuthors.append(CitationAuthor(with: citationAuthorPlist))
            }
        } else  {
            for author in authors {
                plistCitationAuthors.append(CitationAuthor.citationAuthor(with: author))
            }
        }
        
        citationAuthors = plistCitationAuthors
        
        if let authorInfoData = plist["authorInfo"] as? Data {
            var attributedString: NSAttributedString?
#if os(macOS)
            attributedString = NSAttributedString(rtf: authorInfoData, documentAttributes: nil)
#else
            attributedString = try? NSAttributedString(data: authorInfoData, options: [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.rtf], documentAttributes: nil)
#endif
            authorInfo = attributedString ?? NSAttributedString()
        }

        youTubePlaybackHour   = LCitation.int(for: "youTubePlaybackHour", in: plist)
        youTubePlaybackMinute = LCitation.int(for: "youTubePlaybackMinute", in: plist)
        youTubePlaybackSecond = LCitation.int(for: "youTubePlaybackSecond", in: plist)
        
        date = plist["date"] as? Date
        dateAccessed = LCitation.date(for: "dateAccessed", in: plist)
        webAddress   = LCitation.string(for: "webAddress", in: plist)
        source       = LCitation.string(for: "source", in: plist)
        
        dayComponent   = LCitation.int(for: "dayComponent", in: plist)
        yearComponent  = LCitation.int(for: "yearComponent", in: plist)
        monthComponent = LCitation.int(for: "monthComponent", in: plist)
        
        note         = LCitation.string(for: "note", in: plist)
        quote        = LCitation.string(for: "quote", in: plist)
        originalText = LCitation.string(for: "originalText", in: plist)
        
        location    = LCitation.string(for: "location", in: plist)
        publisher   = LCitation.string(for: "publisher", in: plist)
        publication = LCitation.string(for: "publication", in: plist)
        issue       = LCitation.string(for: "issue", in: plist)
        isbn        = LCitation.string(for: "isbn", in: plist)
        asin        = LCitation.string(for: "asin", in: plist)
        doi         = LCitation.string(for: "doi", in: plist)
        issn        = LCitation.string(for: "issn", in: plist)
        pubMed      = LCitation.string(for: "pubMed", in: plist)
        arXiv       = LCitation.string(for: "arXiv", in: plist)
        volume      = LCitation.string(for: "volume", in: plist)
        
        series = LCitation.string(for: "series", in: plist)
        
        editor  = LCitation.string(for: "editor", in: plist)
        journal = LCitation.string(for: "journal", in: plist)
        
        pageRangeStart = LCitation.int(for: "pageRangeStart", in: plist)
        pageRangeEnd   = LCitation.int(for: "pageRangeEnd", in: plist)
        pageRange      = LCitation.string(for: "pageRange", in: plist)
        
        hasSaved = LCitation.bool(for: "hasSaved", in: plist)
        
        isAnonymous = LCitation.bool(for: "isAnonymous", in: plist)
        
        averageRating = plist["averageRating"] as? Double
        ratingCount   = plist["ratingCount"] as? Int
        
        if let identifiers = plist["industryIdentifiers"] as? [[String: Any]] {
            industryIdentifiers = identifiers
        }
        
        bibTeXType = LCitation.string(for: "bibTeXType", in: plist, defaultValue: "misc")
        
        if (pageRangeStart > 0) && LCitation.string(for: "pageRange", in: plist).isEmpty {
            if pageRangeStart < pageRangeEnd {
                pageRange = "\(pageRangeStart)-\(pageRangeEnd)"
            } else {
                pageRange = "\(pageRangeStart)"
            }
        }
    }
    
//    public var bibTeXRecord: BibTeXRecord {
//        get {
//            var record = BibTeXRecord(type: bibTeXType, additionalMetadata: bibTeXID)
//
//            if let creatorString = bibTexCreatorString {
//                record.addEntryWith(key: "author", value: creatorString)
//            }
//
//            if !editor.isEmpty {
//                record.addEntryWith(key: "editor", value: editor)
//            }
//
//            if !title.isEmpty {
//                record.addEntryWith(key: "title", value: title)
//            }
//
//            if let filename = filename, !filename.isEmpty {
//                record.addEntryWith(key: "filename", value: filename)
//            }
//
//            if !journal.isEmpty {
//                record.addEntryWith(key: "journal", value: journal)
//            }
//
//            if !publication.isEmpty {
//                record.addEntryWith(key: "publication", value: publication)
//            }
//
//            if !publisher.isEmpty {
//                record.addEntryWith(key: "publisher", value: publisher)
//            }
//
//            if yearComponent != -1 {
//                record.addEntryWith(key: "year", value: String(describing: yearComponent))
//            }
//
//            if monthComponent != -1 {
//                record.addEntryWith(key: "month", value: String(describing: monthComponent))
//            }
//
//            if !location.isEmpty {
//                record.addEntryWith(key: "address", value: location)
//            }
//
//            if !webAddress.isEmpty {
//                record.addEntryWith(key: "url", value: webAddress)
//            }
//
//
//            if !arXiv.isEmpty {
//                record.addEntryWith(key: "arXiv", value: arXiv)
//            }
//
//            if !asin.isEmpty {
//                record.addEntryWith(key: "asin", value: asin)
//            }
//
//            if !doi.isEmpty {
//                record.addEntryWith(key: "doi", value: doi)
//            }
//
//            if !isbn.isEmpty {
//                record.addEntryWith(key: "isbn", value: isbn)
//            }
//
//            if !issue.isEmpty {
//                record.addEntryWith(key: "issue", value: issue)
//            }
//
//            if let pageRangeBibTexString = pageRangeBibTexString {
//                record.addEntryWith(key: "pages", value: pageRangeBibTexString)
//            }
//
//            if !pubMed.isEmpty {
//                record.addEntryWith(key: "pubMed", value: pubMed)
//            }
//
//            if !volume.isEmpty {
//                record.addEntryWith(key: "volume", value: volume)
//            }
//
//            if !note.isEmpty {
//                record.addEntryWith(key: "note", value: note)
//            }
//
//            return record
//        }
//        set {}
//    }
    
    public var bibTeX: String {
        get {
            var bibTexString = ""
            bibTexString.append("@\(bibTeXType){\(bibTeXID),¶\n")
            
            if let creatorString = bibTexCreatorString {
                bibTexString.append(" author = {\(creatorString)},¶\n")
            }
            
            if !title.isEmpty {
                bibTexString.append(" title = {\(title)},¶\n")
            }
            
            if let filename = filename, !filename.isEmpty {
                bibTexString.append(" filename = {\(filename)},¶\n")
            }
            
            if !journal.isEmpty {
                bibTexString.append(" journal = {\(journal)},¶\n")
            }
            
            if !editor.isEmpty {
                bibTexString.append(" editor = {\(editor)},¶\n")
            }
            
            if yearComponent != -1 {
                bibTexString.append(" year = \(yearComponent),¶\n")
            }
            
            if monthComponent != -1 {
                bibTexString.append(" month = \(monthComponent),¶\n")
            }
            
            if !location.isEmpty {
                bibTexString.append(" address = {\(location)},¶\n")
            }

            if !webAddress.isEmpty {
                bibTexString.append(" url = {\(webAddress)},¶\n")
            }
            
            
            if !arXiv.isEmpty {
                bibTexString.append(" arXiv = {\(arXiv)},¶\n")
            }
            
            if !asin.isEmpty {
                bibTexString.append(" asin = {\(asin)},¶\n")
            }
            
            if !doi.isEmpty {
                bibTexString.append(" doi = {\(doi)},¶\n")
            }
            
            if !isbn.isEmpty {
                bibTexString.append(" isbn = {\(isbn)},¶\n")
            }
            
            if !issue.isEmpty {
                bibTexString.append(" issue = {\(issue)},¶\n")
            }
            
            if let pageRangeBibTexString = pageRangeBibTexString {
                bibTexString.append(" pages = {\(pageRangeBibTexString)},¶\n")
            }

            if !publication.isEmpty {
                bibTexString.append(" publication = {\(publication)},¶\n")
            }
            
            if !publisher.isEmpty {
                bibTexString.append(" publisher = {\(publisher)},¶\n")
            }
            
            if !pubMed.isEmpty {
                bibTexString.append(" pubMed = {\(pubMed)},¶\n")
            }
            
            if !volume.isEmpty {
                bibTexString.append(" volume = {\(volume)},¶\n")
            }
            
            if !note.isEmpty {
                bibTexString.append(" note = {\(note)},¶\n")
            }
            
            bibTexString.append("}\n\n")
            
            return bibTexString
        }
        set {}
    }
    
    var previewDestination: LCitationPreviewDestination {
        // I just... I'm sorry, but it has to be this way for now
        guard let _ = webURL else { return .author }
        
        var authorIsEmpty = true
        
        if let author = author {
            authorIsEmpty = author.isEmpty
        }
        
        if title.isEmpty &&
            authorInfo.length == 0 &&
            note.isEmpty &&
            quote.isEmpty &&
            originalText.isEmpty &&
            location.isEmpty &&
            publisher.isEmpty &&
            publication.isEmpty &&
            issue.isEmpty &&
            isbn.isEmpty &&
            asin.isEmpty &&
            doi.isEmpty &&
            issn.isEmpty &&
            pubMed.isEmpty &&
            arXiv.isEmpty &&
            authorIsEmpty {
            return .browser
        }
        
        return .author
    }
    
    public var webURL: URL? {
        guard let url = URL(string: webAddress) else { return nil }
        return url
    }
    
    var bibTexCreatorString: String? {
        guard !isAnonymous, !citationAuthors.isEmpty else { return nil }
        
        
        if citationAuthors.count == 1,
            let author = citationAuthors.first,
            let fullName = author.fullName {
            return fullName
        } else {
            var lastNamesArray: [String] = []
            for citationAuthor in citationAuthors {
                if let fullName = citationAuthor.fullName {
                    lastNamesArray.append(fullName)
                }
            }
            return lastNamesArray.joined(separator: " and ")
        }
    }
    
    var creatorString: String? {
        if isAnonymous {
            return NSLocalizedString("Anon", comment: "Anonymous author name")
        }
        
        if authors.count > 0 {
            var lastNamesArray: [String] = []
            for citationAuthor in citationAuthors {
                if let lastName = citationAuthor.lastName {
                    lastNamesArray.append(lastName)
                }
            }
            return lastNamesArray.joined(separator: ", ")
            
        }
        
        if domain.count > 0 {
            return domain
        }
        
        return nil
    }
    
    var blockQuoteCreatorString: String? {
        if isAnonymous {
            return NSLocalizedString("Anon", comment: "Anonymous author name")
        }
        
        if authors.count > 0 {
            var lastNamesArray: [String] = []
            for citationAuthor in citationAuthors {
                if let lastName = citationAuthor.lastName {
                    lastNamesArray.append(lastName)
                }
            }
            return lastNamesArray.joined(separator: ", ")
            
        }
        
        if domain.count > 0 {
            return domain
        }
        
        return nil
    }
    
    func creator(for format: LCitationFormat) -> String? {
        if isAnonymous {
            return NSLocalizedString("Anon", comment: "Anonymous author name")
        } else if format == .attachment,
                  let localizedLastNames = authorCollection.localizedLastNames {
            return localizedLastNames
        } else if format == .blockQuoteWithName,
                  let localizedFirstAndLastNames = authorCollection.localizedFirstAndLastNames {
            return localizedFirstAndLastNames
        } else if let formattedLastNames = authorCollection.formattedLastNames {
            return formattedLastNames
        } else if (webAddress.count > 0),
                  let url = URL(string: webAddress),
                  let host = url.host {
            return host
        }
        
        return nil
    }
    
    public func refreshDateComponents() {
        if let date = date {
            let dateComponents = NSCalendar.autoupdatingCurrent.dateComponents([.day, .month, .year], from: date)
            if let day = dateComponents.day {
                dayComponent = day
            }
            
            if let month = dateComponents.month {
                monthComponent = month
            }
            
            if let year = dateComponents.year {
                yearComponent = year
            }
        }
    }
    
    public var bibliographyAuthor: String {
        if let authorsName = creator(for: .italicText) {
            return authorsName
        }
        
        return ""
    }
    
    public var dateString: String? {
        if yearComponent != -1 {
            return "\(yearComponent)"
        }
        
        return nil
    }
    
    public var domain: String {
        guard let url = URL(string: webAddress),
            let host = url.host else { return "" }
        
        return host
    }
    
    public var dateComponents: DateComponents? {
        if dayComponent == -1 && monthComponent == -1 && yearComponent == -1 {
            return nil
        }
        
        var dateComponents = DateComponents()
        
        if dayComponent != -1 {
            dateComponents.day = dayComponent
        }
        
        if monthComponent != -1 {
            dateComponents.month = monthComponent
        }
        
        if yearComponent != -1 {
            dateComponents.year = yearComponent
        }
        
        
        return dateComponents
    }
    
    public var hasPageRange: Bool {
        if !pageRange.isEmpty {
            return true
        }
        
        return (pageRangeStart > 0)
    }
    
    public var pageRangeString: String {
        if !pageRange.isEmpty {
            return pageRange
        }
        
        if hasPageRange == false {
            return ""
        }
        
        if pageRangeStart < pageRangeEnd {
            return "pp. \(pageRangeStart)-\(pageRangeEnd)"
        } else {
            return "p. \(pageRangeStart)"
        }
    }
    
    public var pageRangeBibTexString: String? {
        if !pageRange.isEmpty {
            return pageRange
        }
        
        guard hasPageRange else { return nil }
        
        if pageRangeStart < pageRangeEnd {
            return "\(pageRangeStart)-\(pageRangeEnd)"
        } else {
            return "\(pageRangeStart)"
        }
    }
    
        
    static func string(for key: String, in plist: [AnyHashable: Any], defaultValue: String = "") -> String {
        if let value = plist[key] as? String {
            return value
        }
        
        return defaultValue
    }
    
    static func date(for key: String, in plist: [AnyHashable: Any]) -> Date {
        if let value = plist[key] as? Date {
            return value
        }
        
        return Date()
    }
    
    static func int(for key: String, in plist: [AnyHashable: Any]) -> Int {
        if let value = plist[key] as? Int {
            return value
        }
        
        return -1
    }
    
    static func bool(for key: String, in plist: [AnyHashable: Any]) -> Bool {
        if let value = plist[key] as? Bool {
            return value
        }
        
        return false
    }
    
    public override init() {}
    
#if os(macOS)
    static func convert(font: PlatformFont, toHave fontTraits: [NSFontTraitMask]) -> PlatformFont {
        let fontManager = NSFontManager.shared
        var convertedFont = font
        for fontTrait in fontTraits {
            convertedFont = fontManager.convert(convertedFont, toHaveTrait: fontTrait)
        }
        return convertedFont
    }
    
    static func convert(font: PlatformFont, toNotHave fontTraits: [NSFontTraitMask]) -> PlatformFont {
        let fontManager = NSFontManager.shared
        var convertedFont = font
        for fontTrait in fontTraits {
            convertedFont = fontManager.convert(convertedFont, toNotHaveTrait: fontTrait)
        }
        return convertedFont
    }
    
    static func contentAttributedString(for format: LCitationFormat,
                                               with attributedString: NSAttributedString) -> NSAttributedString {
        let mutableAttributedString = NSMutableAttributedString(attributedString: attributedString)
        
        if format == .italicText || format == .italicTextWithNameAndYear {
            mutableAttributedString.beginEditing()
            
            mutableAttributedString.enumerateAttribute(.font, in: NSMakeRange(0, mutableAttributedString.length), options: [], using: { (value, range, _) in
                if let font = value as? PlatformFont {
                    let italicFont = LCitation.convert(font: font, toHave: [.italicFontMask])
                    mutableAttributedString.removeAttribute(.font, range: range)
                    mutableAttributedString.addAttribute(.font, value: italicFont, range: range)
                }
            })
            
            mutableAttributedString.endEditing()
        } else {
            mutableAttributedString.beginEditing()
            
            mutableAttributedString.enumerateAttribute(.font, in: NSMakeRange(0, mutableAttributedString.length), options: [], using: { (value, range, _) in
                if let font = value as? PlatformFont {
                    let italicFont = LCitation.convert(font: font, toNotHave: [.italicFontMask])
                    mutableAttributedString.removeAttribute(.font, range: range)
                    mutableAttributedString.addAttribute(.font, value: italicFont, range: range)
                }
            })
            
            mutableAttributedString.endEditing()
        }
        
        return mutableAttributedString
    }
    
    static func attributedStringRemoving(format: LCitationFormat,
                                                with attributedString: NSAttributedString) -> NSAttributedString {
        let mutableAttributedString = NSMutableAttributedString(attributedString: attributedString)
        
        if format == .italicTextWithNameAndYear {
            mutableAttributedString.beginEditing()
            
            mutableAttributedString.enumerateAttribute(.font, in: NSMakeRange(0, mutableAttributedString.length), options: [], using: { (value, range, _) in
                if let font = value as? PlatformFont {
                    let italicFont = LCitation.convert(font: font, toNotHave: [.italicFontMask])
                    mutableAttributedString.removeAttribute(.font, range: range)
                    mutableAttributedString.addAttribute(.font, value: italicFont, range: range)
                }
            })
            
            mutableAttributedString.endEditing()
        }
        
        return mutableAttributedString
    }
#endif
    
    var isAmazon: Bool {
        return creationSource == "amazon"
    }
    
    var isVideo: Bool {
        return creationSource == "youtube"
    }
    
}
