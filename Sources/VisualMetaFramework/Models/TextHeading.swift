import Foundation
import PDFKit

public enum TextStyleIdentifier: String {
    case heading1
    case heading2
    case heading3
    case heading4
    case heading5
    case heading6
    case body
}

extension TextStyleIdentifier {
    
    static var maximumHeadingTextStyleIdentifiers: Set<TextStyleIdentifier> {
        return Set<TextStyleIdentifier>([.heading1, .heading2, .heading3, .heading4, .heading5, .heading6])
    }
    
    static var minimumHeadingTextStyleIdentifiers: Set<TextStyleIdentifier> {
        return Set<TextStyleIdentifier>([.heading1])
    }
    
}

public struct TextHeading {
    public let identifier: String = UUID().uuidString
    public let textStyleIdentifier: TextStyleIdentifier
    public let selection: PDFSelection
    public let attributedString: NSAttributedString
    public let showInFind: Bool
    public let author: String?
    
    public init(textStyleIdentifier: TextStyleIdentifier, selection: PDFSelection, attributedString: NSAttributedString, showInFind: Bool, author: String?) {
        self.textStyleIdentifier = textStyleIdentifier
        self.selection = selection
        self.attributedString = attributedString
        self.showInFind = showInFind
        self.author = author
    }
}

extension TextHeading: CustomDebugStringConvertible {
    public var debugDescription: String {
        return attributedString.string
    }
}

extension TextHeading {
    
    public var levelInt: Int?  {
        
        switch textStyleIdentifier {
        case .heading1:
            return 1
        case .heading2:
            return 2
        case .heading3:
            return 3
        case .heading4:
            return 4
        case .heading5:
            return 5
        case .heading6:
            return 6
        default:
            return nil
        }
        
    }
}
