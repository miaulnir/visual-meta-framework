enum VisualMetaTags {
    static let visualMeta      = VisualMetaTag("visual-meta")
    static let selfCitation    = VisualMetaTag("visual-meta-bibtex-self-citation")
	static let fullText 	   = VisualMetaTag("visual-meta-full-document-text")
    static let referencesIndex = VisualMetaTag("references-index")
    static let reference       = VisualMetaTag("references")
    static let glossary        = VisualMetaTag("glossary")
    static let endnotes        = VisualMetaTag("endnotes")
    static let headings        = VisualMetaTag("document-headings")
    static let paraText        = VisualMetaTag("paraText")
}

public class VisualMetaTag: Equatable {
    
    let tag: String
    
    private let preffix     = "@{"
    private let startSuffix = "-start}"
    private let endSuffix   = "-end}"
    
    public var startTag: String {
        get {
            return preffix + tag + startSuffix
        }
    }
    
    public var startTagWithoutBrace: String {
        get {
            return String(startTag.dropLast())
        }
    }
    
    public var endTag: String {
        get {
            return preffix + tag + endSuffix
        }
    }
    
    public var endTagWithoutBrace: String {
        get {
            return String(endTag.dropLast())
        }
    }
    
    init(_ tag: String) {
        self.tag = tag
    }
    
    public static func == (lhs: VisualMetaTag, rhs: VisualMetaTag) -> Bool {
        return lhs.tag == rhs.tag
    }
}
