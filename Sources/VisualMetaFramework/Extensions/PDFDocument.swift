import PDFKit

extension PDFDocument {
    
     func selection(from start: PDFSelection, to end: PDFSelection) -> PDFSelection? {

        guard let startPoint = start.endPointOnPage(),
              let endPoint = end.endPointOnPage() else { return nil }
        return selection(from: startPoint.page, at: startPoint.point, to: endPoint.page, at: endPoint.point)
    }
    
     func selection(extending start: PDFSelection, to end: PDFSelection) -> PDFSelection? {
        
        guard let startPoint = start.startPointOnPage(),
              let endPoint = end.endPointOnPage() else { return nil }
        return selection(from: startPoint.page, at: startPoint.point, to: endPoint.page, at: endPoint.point)
    }
    
}
