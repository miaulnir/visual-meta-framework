import Foundation

public final class CitationAuthorCollection: NSObject {
    @objc public dynamic var authors = [CitationAuthor]()
    
    var nameFormatter: PersonNameComponentsFormatter = {
        let personNameComponentsFormatter = PersonNameComponentsFormatter()
        personNameComponentsFormatter.style = .medium
        
        return personNameComponentsFormatter
    }()
    
    @objc public dynamic var formattedAuthorNames: String? {
        get {
            let authorsCount = authors.count
            
            switch authorsCount {
            case 1:
                
                if let firstAuthor = authors.first {
                    return formattedName(for: firstAuthor)
                }
                return "Error"
            case 2:
                let firstAuthorName = formattedName(for: authors[0])
                let secondAuthorName = formattedName(for: authors[1])
                
                return "\(firstAuthorName) & \(secondAuthorName)"
                
            case 3 ... 6:
                var authorNames: [String] = []
                for author in authors {
                    if let shortName = author.shortName {
                        authorNames.append(shortName)
                    }
                }
                return authorNames.joined(separator: ", ")
                
            case let x where x > 6:
                let firstAuthorName = formattedName(for: authors[0])
                let secondAuthorName = formattedName(for: authors[1])
                
                return "\(firstAuthorName), \(secondAuthorName), et al."
            default:
                return ""
            }
        }
        set {}
    }
    
    @objc public dynamic var formattedLastNames: String? {
        get {
            let authorsCount = authors.count
            
            switch authorsCount {
            case 1:
                
                for author in authors {
                    if let shortName = author.shortName {
                        return shortName
                    }
                }
            case 2:
                let firstAuthor = authors[0]
                let secondAuthor = authors[1]
                
                if let first = firstAuthor.shortName,
                    let second = secondAuthor.shortName {
                    return "\(first) & \(second)"
                }
                
            case 3 ... 6:
                var authorNames: [String] = []
                for author in authors {
                    if let shortName = author.shortName {
                        authorNames.append(shortName)
                    }
                }
                return authorNames.joined(separator: ", ")
                
            case let x where x > 6:
                let firstAuthor = authors[0]
                let secondAuthor = authors[1]
                
                if let first = firstAuthor.shortName,
                    let second = secondAuthor.shortName {
                   return "\(first), \(second), et al."
                }
                
            default:
                return nil
            }
            
            return nil
        }
        set {}
    }
    
    @objc public dynamic var condensedFormattedAuthorNames: String? {
        get {
            let authorsCount = authors.count
            
            switch authorsCount {
            case 1:
                
                if let firstAuthor = authors.first {
                    return condensedFormattedName(for: firstAuthor)
                }
                return "Error"
            case 2:
                if let firstAuthorName = condensedFormattedName(for: authors[0]),
                    let secondAuthorName = condensedFormattedName(for: authors[1]) {
                
                    return "\(firstAuthorName) & \(secondAuthorName)"
                }
                
            case 3 ... 6:
                var authorNames: [String] = []
                for author in authors {
                    if let name = condensedFormattedName(for: author) {
                        authorNames.append(name)
                    }
                }
                return authorNames.joined(separator: " & ")
                
            case let x where x > 6:
                if let firstAuthorName = condensedFormattedName(for: authors[0]),
                    let secondAuthorName = condensedFormattedName(for: authors[1]) {
                    
                    return "\(firstAuthorName) & \(secondAuthorName), et al."
                }
            default:
                return ""
            }
            
            return ""
        }
        set {}
    }
    
    
    
    @objc public dynamic var fullLocalizedNames: String? {
        get {
            var authorNames: [String] = []
            for author in authors {
                if let fullName = author.fullName {
                    authorNames.append(fullName)
                }
            }
            return authorNames.joined(separator: ", ")
        }
        set {}
    }
    
    @objc public dynamic var namesForCitationIdentifier: String? {
        get {
            var authorNames: [String] = []
            for author in authors {
                if let fullName = author.fullName {
                    authorNames.append(fullName)
                }
            }
            
            
            var nameString = authorNames.joined(separator: "")
            nameString.lowercaseFirstLetter()
            return nameString.replacingOccurrences(of: " ", with: "")
        }
        set {}
    }
    
    @objc public dynamic var localizedFirstAndLastNames: String? {
        get {
            var authorNames: [String] = []
            for author in authors {
                if let fullName = author.firstAndLast {
                    authorNames.append(fullName)
                }
            }
            return authorNames.joined(separator: ", ")
        }
        set {}
    }

    @objc public dynamic var localizedFirstAndLastNamesShort: String? {
        get {
            var authorNames: [String] = []
            for author in authors {
                if let fullName = author.firstAndLastShort {
                    authorNames.append(fullName)
                }
            }
            return authorNames.joined(separator: ", ")
        }
        set {}
    }

    @objc public dynamic var localizedLastNames: String? {
        get {
            var authorNames: [String] = []
            for author in authors {
                if let lastName = author.lastName, !lastName.isEmpty {
                    authorNames.append(lastName)
                } else if let firstName = author.firstName, !firstName.isEmpty {
                    authorNames.append(firstName)
                }
            }
            return authorNames.joined(separator: ", ")
        }
        set {}
    }
    
    public func formattedName(for author: CitationAuthor) -> String {
        var personNameComponents = PersonNameComponents()
        personNameComponents.givenName = author.firstName
        personNameComponents.middleName = author.middleName
        personNameComponents.familyName = author.lastName
        
        return nameFormatter.string(from: personNameComponents)
    }
    
    public func condensedFormattedName(for author: CitationAuthor) -> String? {
        if let lastName = author.lastName,
            let firstName = author.firstName {
            let firstNameString = firstName as NSString
            
            if firstNameString.length > 0 {
                let firstInitial = firstNameString.substring(to: 1)
                return "\(lastName), \(firstInitial)."
            }
            
        } else if let lastName = author.lastName {
            return lastName
        } else if let firstName = author.firstName {
            return firstName
        }
        
        return nil
    }
}
