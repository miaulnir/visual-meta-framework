import PDFKit

class HeadingIndexer { // FOTIndexer
    let selections: [PDFSelection]
    let headings  : [Heading] // sections
    
    init(with selections: [PDFSelection], headings: [Heading]) {
        self.selections = selections
        self.headings = headings
    }
    
    func getTextHeadings() -> [TextHeading] { // indexing
        guard !headings.isEmpty else { return [] }
        var textContainers: [TextHeading] = []
        var headingIndex = 0
        
        for (index, selection) in selections.enumerated() {
            guard let heading = headings[safe: headingIndex],
                  let attributedString = selection.attributedString?.trimmed,
                  !attributedString.isEmpty else { continue }
            let selectionString = attributedString.string
            
            let trimmedHeadingName     = heading.name.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: " ", with: "")
            let trimmedSelectionString = selectionString.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: " ", with: "")
            if trimmedHeadingName.hasPrefix(trimmedSelectionString),
               let container = textContainer(for: heading,
                                             startingAtSelection: index) {
                textContainers.append(container)
                headingIndex += 1
            }
        }
        return textContainers
    }
}

private extension HeadingIndexer {
    
    func textContainer(for heading: Heading, startingAtSelection index: Int) -> TextHeading? {
        guard let sectionSelection = selections[safe: index]  else { return nil }
        
        return textContainer(for: sectionSelection,
                             title: heading.name,
                             textStyleIdentifier: heading.textStyleIdentifier,
                             showInFind: heading.showInFind ?? true,
                             author: heading.author)
    }
    
    func textContainer(for sectionSelection: PDFSelection, title: String, textStyleIdentifier: TextStyleIdentifier, showInFind: Bool, author: String? = nil) -> TextHeading? {
        guard let _ = sectionSelection.attributedString?.trimmed  else { return nil }
        let font = PlatformFont(name: "Georgia", size: 12.00) ?? PlatformFont.systemFont(ofSize: PlatformFont.labelFontSize)
        let mutableAttributedString = NSMutableAttributedString(attributedString: NSAttributedString(string: title))
        
        mutableAttributedString.addAttribute(.font, value: font)
        
        return TextHeading(textStyleIdentifier: textStyleIdentifier,
                           selection: sectionSelection,
                           attributedString: mutableAttributedString,
                           showInFind: showInFind,
                           author: author)
    }
}
