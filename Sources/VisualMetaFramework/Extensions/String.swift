import Foundation

extension String {
    
    mutating func remove(characters: String) {
        for character in characters {
            self = replacingOccurrences(of: String(character), with: "")
        }
    }
    
    func lowercasingFirstLetter() -> String {
        let first = String(prefix(1)).lowercased()
        let other = String(dropFirst())
        return first + other
    }
    
    mutating func lowercaseFirstLetter() {
        self = self.lowercasingFirstLetter()
    }
    
    func trailingTrim(_ characterSet : CharacterSet) -> String {
        if let range = rangeOfCharacter(from: characterSet, options: [.anchored, .backwards]) {
            return String(self[..<range.lowerBound])
        }
        return self
    }
    
    func getSuffix(after: Self) -> Self {
        if let index = (self.range(of: after)?.upperBound) {
            return String(self.suffix(from: index))
        }
        return self
    }
    
    /// Get string between two tags "some text tag.startTag bla bla bla tag.startTag some text" -> " bla bla bla "
    func getString(between tag: VisualMetaTag) -> String? {
        return (range(of: tag.startTag)?.upperBound).flatMap { substringFrom in
            (range(of: tag.endTag, range: substringFrom..<endIndex)?.lowerBound).map { substringTo in
                String(self[substringFrom..<substringTo])
            }
        }
    }
    
    func insertNewlinesBeforeOccurrences(of string: String) -> String {
        let rangesOfString = ranges(of: string).reversed()
        var selfString = self

        for range in rangesOfString {
            if range.location > 0,
               isWhitespace(before: range.location),
               let swiftRange = Range(range, in: selfString) {
                selfString.insert(contentsOf: "\n\n", at: swiftRange.lowerBound)
            }
        }
        return selfString
    }
    
    var containsWithBibTexInitializer: Bool {
        do {
            let pattern = #"@(.*?)\{"#
            let regex = try NSRegularExpression(pattern: pattern, options: [])
            let nsrange = NSRange(self.startIndex..<self.endIndex, in: self)

            let matches = regex.matches(in: self, options: [], range: nsrange)
            for match in matches {
                if match.range.length > 2 {
                    return true
                }
            }
        } catch let error {
            print("error: \(error)")
        }
        return false
    }
    
    func ranges(of searchString: String) -> [NSRange] {
        let selfString = self as NSString
        var searchRange = NSRange(location: 0, length: selfString.length)
        var ranges: [NSRange] = []
        while searchRange.location < selfString.length {
            searchRange.length = selfString.length - searchRange.location
            let foundRange = selfString.range(of: searchString, options: .caseInsensitive, range: searchRange)
            if foundRange.location != NSNotFound {
                searchRange.location = foundRange.location + foundRange.length
                ranges.append(foundRange)
            }
            else {
                break
            }
        }

        return ranges
    }

    func isWhitespace(before index: Int) -> Bool {
        if index > 0 {
            let string = self as NSString
            let beforeSymbol = string.substring(with: NSMakeRange(index - 1, 1))

            guard let unicodeScalar = beforeSymbol.unicodeScalars.first else { return false }
            return CharacterSet.whitespacesAndNewlines.contains(unicodeScalar)
        }
        return false
    }
    
    func matches(regex pattern: String) -> [String]? {
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return nil }
        let range = NSRange(location: 0, length: self.utf16.count)
        
        let matches = regex.matches(in: self, range: range)
        let nsString = self as NSString
        return matches.map({ nsString.substring(with: $0.range) })
    }
}
