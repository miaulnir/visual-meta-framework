//
//  File.swift
//  
//
//  Created by Игорь Бареев on 07.07.2023.
//

import Foundation

public struct BibTeXSupport {
    
    public enum EntryType: String, CaseIterable {
        case article
        case book
        case booklet
        case conference
        case inbook
        case incollection
        case inproceedings
        case manual
        case masterthesis
        case misc
        case phdthesis
        case proceedings
        case techreport
        case unpublished
    }
    
    public static func citationInfo(for bibTeXString: String) -> [String: Any]? {
        func _stringTrimming(string: String) -> String {
            let characterSet = CharacterSet(charactersIn: "= {},\"")
            return string.trimmingCharacters(in: characterSet)
        }
        
        let adjustedString = bibTeXString.replacingOccurrences(of: "},", with: "},\n")
        let scanner = Scanner(string: adjustedString)
        
        var string: NSString?
        scanner.scanUpTo("@", into: nil)
        scanner.scanUpTo("{", into: &string)
        
        var citationDictionary = [String: Any]()
        
        citationDictionary["identifier"] = UUID().uuidString
        citationDictionary["creationSource"] = "BibTeX"
        
        if var type = string as String? {
            type.removeFirst(1)
            if !type.isEmpty {
                citationDictionary["bibTeXType"] = type
            }
        }
        
        let characterSet = NSMutableCharacterSet(charactersIn: ",")
        characterSet.formUnion(with: CharacterSet.whitespacesAndNewlines)
        
        scanner.scanUpToCharacters(from: characterSet as CharacterSet, into: &string)
        
        //scanner.scanUpTo("\n", into: &string)
        
        
        let entries = adjustedString.getSuffix(after: "{").components(separatedBy: "¶")
//        var entries = [String]()
//
//        while scanner.scanUpTo("\n", into: &string) {
//            if let entry = string as String?, !entry.isEmpty {
//                entries.append(entry)
//            }
//        }
        
        if entries.isEmpty { return nil }
        
        entries.forEach { entry in
            let keyValueScanner = Scanner(string: entry)
            
            var keyString: NSString?
            keyValueScanner.scanUpTo("=", into: &keyString)
            if keyString != nil {
                keyString = NSString(format: "%@%@", keyString!, "=")
            }
            
            var valueString: NSString?
            keyValueScanner.scanUpTo(",\n", into: &valueString)

            if let key = keyString, let value = valueString {
                let trimmedKey = _stringTrimming(string: key as String)
                let trimmedValue = _stringTrimming(string: value as String)
                 
                if trimmedKey == "address" || key.contains("address =") {
                    citationDictionary["location"] = trimmedValue
                }
                    
                else if trimmedKey == "author" || key.contains("author =") {
                    citationDictionary["citationAuthors"] = BibTeXSupport.citationAuthors(for: trimmedValue)
                }
                    
                else if trimmedKey == "booktitle" || key.contains("booktitle =") {
                    citationDictionary["publication"] = trimmedValue
                }
                    
                else if trimmedKey == "doi" || key.contains("doi =") {
                    citationDictionary["doi"] = trimmedValue
                }
                    
                else if trimmedKey == "editor" || key.contains("editor =") {
                    citationDictionary["editor"] = trimmedValue
                }
                
                else if trimmedKey == "journal" || key.contains("journal =") {
                    citationDictionary["journal"] = trimmedValue
                }
                
                else if trimmedKey == "asin" || key.contains("asin =") {
                    citationDictionary["asin"] = trimmedValue
                }
                    
                else if trimmedKey == "isbn" || key.contains("isbn =") {
                    citationDictionary["isbn"] = trimmedValue
                }
                    
                else if trimmedKey == "issn" || key.contains("issn =") {
                    citationDictionary["issn"] = trimmedValue
                }
                    
                else if trimmedKey == "monthComponent",
                    let monthComponent = BibTeXSupport.monthComponent(for: trimmedValue as String) {
                    citationDictionary["monthComponent"] = monthComponent
                }
                    
                else if trimmedKey == "note" || key.contains("note =") {
                    citationDictionary["note"] = trimmedValue
                }
                    
                else if trimmedKey == "title" || key.contains("title =") {
                    citationDictionary["title"] = trimmedValue
                    
                    // FIXME: - only for test
//                    citationDictionary["filename"] = "PhD after Viva  January 2023 after submission.pdf"
//                    let longText = "Here will be original text bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla"
//                    let shortText = "Here will be original text"
//                    if Bool.random() {
//                        citationDictionary["originalText"] = Bool.random() ? shortText : longText
//                    }
//                    citationDictionary["pageRange"] = "15--18"
                    // ----------------------
                }
                
                else if trimmedKey == "filename" || key.contains("filename =") {
                    citationDictionary["filename"] = trimmedValue
                }
                    
                else if trimmedKey == "pageRange" || key.contains("pageRange =") {
                    citationDictionary["pageRange"] = trimmedValue
                }
                    
                else if trimmedKey == "publisher" || key.contains("publisher =") {
                    citationDictionary["publisher"] = trimmedValue
                }
                    
                else if trimmedKey == "volume" || key.contains("volume =") {
                    citationDictionary["volume"] = trimmedValue
                }
                    
                else if trimmedKey == "yearComponent",
                    let yearComponent = BibTeXSupport.yearComponent(for: trimmedValue as String) {
                    citationDictionary["yearComponent"] = yearComponent
                }

                else if trimmedKey == "year",
                    let yearComponent = BibTeXSupport.yearComponent(for: trimmedValue as String) {
                    citationDictionary["yearComponent"] = yearComponent
                }

                else if trimmedKey == "series" || key.contains("series =") {
                    citationDictionary["series"] = trimmedValue
                }
                    
                else if trimmedKey == "url" || key.contains("url =") {
                    citationDictionary["webAddress"] = trimmedValue
                }
                    
                else if trimmedKey == "keywords" || key.contains("keywords =") {
                    citationDictionary["note"] = trimmedValue
                }
                
                else if trimmedKey == "pagecited" || key.contains("pagecited =") {
                    citationDictionary["pagecited"] = trimmedValue
                }
                
                else if trimmedKey == "quote" || key.contains("quote =") {
                    citationDictionary["quote"] = trimmedValue
                }
                
            }
        }
        
        return citationDictionary
    }
    
    public static func monthComponent(for string: String) -> Int? {
        
        if let monthInt = Int(string),
            (1 ... 12 ~= monthInt) {
            return monthInt
        }
        
        let name = string.lowercased()
        
        if name == "january" || name == "jan" {
            return 1
        }
            
        else if name == "february" || name == "feb" {
            return 2
        }
            
        else if name == "march" || name == "mar" {
            return 3
        }
            
        else if name == "april" || name == "apr" {
            return 4
        }
            
        else if name == "may" {
            return 5
        }
            
        else if name == "june" || name == "jun" {
            return 6
        }
            
        else if name == "july" || name == "jul" {
            return 7
        }
            
        else if name == "august" || name == "aug" {
            return 8
        }
            
        else if name == "september" || name == "sep" || name == "sept" {
            return 9
        }
            
        else if name == "october" || name == "oct" {
            return 10
        }
            
        else if name == "november" || name == "nov" {
            return 11
        }
            
        else if name == "december" || name == "dec" {
            return 12
        }
        
        return nil
    }
    
    public static func yearComponent(for string: String) -> Int? {
        return Int(string)
    }
    
    public static func citationAuthors(for string: String) -> [[String : Any]] {
        var components = [String]()
        
        if string.contains(" and ") {
            components = string.components(separatedBy: " and ")
        } else {
            components = [string]
        }
        print(components)
        
        let nameFormatter: PersonNameComponentsFormatter = {
            let personNameComponentsFormatter = PersonNameComponentsFormatter()
            personNameComponentsFormatter.style = .long
            
            return personNameComponentsFormatter
        }()
        
        var citationAuthors = [[String : Any]]()
        
        components.forEach { author in
            if let personNameComponents = nameFormatter.personNameComponents(from: author) {
                var citationAuthor = [String: Any]()
                citationAuthor["prefixName"] = personNameComponents.namePrefix
                citationAuthor["firstName"] = personNameComponents.givenName
                citationAuthor["middleName"] = personNameComponents.middleName
                citationAuthor["lastName"] = personNameComponents.familyName
                citationAuthor["suffixName"] = personNameComponents.nameSuffix
                
                if citationAuthor["lastName"] == nil && citationAuthor["firstName"] != nil {
                    citationAuthor["lastName"] = citationAuthor["firstName"]
                    citationAuthor["firstName"] = nil
                }
                
                citationAuthors.append(citationAuthor)
            }
        }
        
        return citationAuthors
    }
    
    
    public static func bibTeXString(from sourceString: String) -> String? {
        let scanner = Scanner(string: sourceString)
        
        var string: NSString?
        scanner.scanUpTo("@", into: nil)
        scanner.scanUpTo("{", into: &string)
        scanner.scanUpTo("\n", into: &string)
        scanner.scanUpTo("\n}", into: &string)
        
        if let finalString = string {
            return finalString as String
        }
        
        return nil
    }
}
