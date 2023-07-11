import Foundation

public struct References {
    private let referenceEntries: [String : ReferenceEntry]
    public let labelAttributedString   : NSAttributedString
    
    public init(with referenceEntries: [String : ReferenceEntry],
                labelAttributedString: NSAttributedString) {
        self.referenceEntries      = referenceEntries
        self.labelAttributedString = labelAttributedString
    }
    
    public func referenceEntry(with identifier: String) -> ReferenceEntry? {
        return referenceEntries[identifier]
    }
    
}

public struct ReferenceEntry {
    
    public let identifier: String
    public let content   : NSAttributedString
    public let filename  : String?
    public let title     : String?
    public let urlString : String?
    public let quote     : String?
    public let pageIndex : Int?
    
    public init (identifier: String,
                 content: NSAttributedString,
                 filename: String? = nil,
                 title: String? = nil,
                 urlString: String? = nil,
                 quote: String? = nil,
                 pageIndex: Int? = nil) {
        self.identifier = identifier
        self.content    = content
        self.filename   = filename
        self.title      = title
        self.urlString  = urlString
        self.quote      = quote
        self.pageIndex  = pageIndex
    }
}
