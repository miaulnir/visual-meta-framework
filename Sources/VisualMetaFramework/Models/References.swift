import Foundation

public struct References {
    private let referenceEntries: [String : ReferenceEntry]
    let labelAttributedString   : NSAttributedString
    
    init(with referenceEntries: [String : ReferenceEntry],
         labelAttributedString: NSAttributedString) {
        self.referenceEntries      = referenceEntries
        self.labelAttributedString = labelAttributedString
    }
    
    func referenceEntry(with identifier: String) -> ReferenceEntry? {
        return referenceEntries[identifier]
    }
    
}

public struct ReferenceEntry {
    
    let identifier: String
    let content   : NSAttributedString
    let filename  : String?
    let title     : String?
    let urlString : String?
    let quote     : String?
    let pageIndex : Int?
    
    init (identifier: String,
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
