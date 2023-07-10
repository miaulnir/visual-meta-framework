import Foundation

var nameFormatter: PersonNameComponentsFormatter = {
    let personNameComponentsFormatter = PersonNameComponentsFormatter()
    personNameComponentsFormatter.style = .long
    
    return personNameComponentsFormatter
}()

public final class CitationAuthor : NSObject {
    @objc public dynamic var prefixName: String?
    @objc public dynamic var firstName : String?
    @objc public dynamic var middleName: String?
    @objc public dynamic var lastName  : String?
    @objc public dynamic var suffixName: String?

    static func citationAuthor(with name: String) -> CitationAuthor {
        let citationAuthor = CitationAuthor()
        if let personNameComponents = nameFormatter.personNameComponents(from: name) {
            citationAuthor.prefixName = personNameComponents.namePrefix
            citationAuthor.firstName  = personNameComponents.givenName
            citationAuthor.middleName = personNameComponents.middleName
            citationAuthor.lastName   = personNameComponents.familyName
            citationAuthor.suffixName = personNameComponents.nameSuffix
        }
        
        return citationAuthor
    }
    
    public var hasContents: Bool {
        
        if let prefix = prefixName, !prefix.isEmpty {
            return true
        }
        
        if let first = firstName, !first.isEmpty {
            return true
        }
        
        if let middle = middleName, !middle.isEmpty {
            return true
        }
        
        if let last = lastName, !last.isEmpty {
            return true
        }
        
        if let suffix = suffixName, !suffix.isEmpty {
            return true
        }
        
        return false
        
    }

    public func plist() -> [String : Any] {
        var plist = [String : Any]()
        
        plist["prefixName"] = prefixName
        plist["firstName"]  = firstName
        plist["middleName"] = middleName
        plist["lastName"]   = lastName
        plist["suffixName"] = suffixName
        
        return plist
    }
    
    public convenience init(with plist: [String: Any]) {
        self.init()
        prefixName = CitationAuthor.string(for: "prefixName", in: plist)
        firstName  = CitationAuthor.string(for: "firstName", in: plist)
        middleName = CitationAuthor.string(for: "middleName", in: plist)
        lastName   = CitationAuthor.string(for: "lastName", in: plist)
        suffixName = CitationAuthor.string(for: "suffixName", in: plist)
    }
    
    public func copy(with zone: NSZone? = nil) -> Any {
        let copy = CitationAuthor()
        
        copy.prefixName = prefixName
        copy.firstName  = firstName
        copy.middleName = middleName
        copy.lastName   = lastName
        copy.suffixName = suffixName
        
        return copy
    }
    
    static func string(for key: String, in plist: [AnyHashable: Any]) -> String {
        if let value = plist[key] as? String {
            return value
        }
        
        return ""
    }
    
    public var shortName: String? {
        if let lastName = lastName {
            return lastName
        } else if let firstName = firstName {
            return firstName
        }
        
        return nil
    }
    
    public var fullName: String? {
        var personNameComponents = PersonNameComponents()
        
        personNameComponents.namePrefix = prefixName
        personNameComponents.givenName  = firstName
        personNameComponents.middleName = middleName
        personNameComponents.familyName = lastName
        personNameComponents.nameSuffix = suffixName
        
        let personName = nameFormatter.string(from: personNameComponents)
        
        if !personName.isEmpty {
            return personName
        }
        
        return nil
    }
    
    public var firstAndLast: String? {
        var personNameComponents = PersonNameComponents()
        
        personNameComponents.givenName  = firstName
        personNameComponents.familyName = lastName
        
        let personName = nameFormatter.string(from: personNameComponents)
        
        if !personName.isEmpty {
            return personName
        }
        
        return nil
    }
}
