import Foundation

extension NSAttributedString {
    
    var trimmed: NSAttributedString {
        return trimming(charSet: .whitespacesAndNewlines)
    }
    
    func trimming(charSet: CharacterSet) -> NSAttributedString {
        let modifiedString = NSMutableAttributedString(attributedString: self)
        modifiedString.trimCharactersInSet(charSet: charSet)
        return NSAttributedString(attributedString: modifiedString)
    }
    
    var isEmpty: Bool {
        return length == 0
    }
    
    var range: NSRange {
        get {
            return NSRange(location: 0, length: length)
        }
    }
}
