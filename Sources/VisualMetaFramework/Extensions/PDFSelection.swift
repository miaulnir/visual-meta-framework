import PDFKit

extension PDFSelection {
    
    func startPointOnPage() -> (point: CGPoint, page: PDFPage)? {
        guard let page = pages.first else { return nil }
        let selectionBounds = bounds(for: page)
        return (CGPoint(x: selectionBounds.minX, y: selectionBounds.maxY), page)
    }
    
    func endPointOnPage() -> (point: CGPoint, page: PDFPage)? {
        guard let page = pages.last else { return nil }
        let selectionBounds = bounds(for: page)
        return (CGPoint(x: selectionBounds.minX, y: selectionBounds.minY), page)
    }
    
}
