import Foundation

public class Heading: Decodable { // FOTSection
    
    enum Level: String, Decodable {
        case one   = "level1"
        case two   = "level2"
        case three = "level3"
        case four  = "level4"
        case five  = "level5"
        case six   = "level6"
    }
    
    init?(jsonDict: [String: Any]) {
        guard let data = try? JSONSerialization.data(withJSONObject: jsonDict),
              let heading = try? JSONDecoder().decode(Self.self, from: data) else { return nil }
        self.name       = heading.name
        self.level      = heading.level
        self.showInFind = heading.showInFind
        self.author     = heading.author
    }
    
    init(name: String, level: Level) {
        self.name       = name
        self.level      = level
        self.showInFind = true
        self.author     = nil
    }
    
    /// The name of the section. For articles, this will be the author name.
    let name: String
    
    /// The heading level of the section
    let level: Level
    
    var showInFind: Bool?
    
    var author: String?
    
}

extension Heading {
    
    var textStyleIdentifier: TextStyleIdentifier {
        switch level {

        case .one:   return .heading1
        case .two:   return .heading2
        case .three: return .heading3
        case .four:  return .heading4
        case .five:  return .heading5
        case .six:   return .heading6
        }
    }
}

extension Heading: CustomDebugStringConvertible {
    
    public var debugDescription: String {
        return "Section: `\(name)`"
    }
    
}
