import Foundation

extension FileManager {

    static func generateFileURL(_ fileExtension: String = "jpg") -> URL {
        return FileManager.default.generateFileURL(fileExtension)
    }
    
    func generateFileURL(_ fileExtension: String = "jpg") -> URL {
        let fileManager = self
        let fileArray: NSArray = fileManager.urls(for: .cachesDirectory, in: .userDomainMask) as NSArray
        let fileURL = (fileArray.lastObject as? URL)?.appendingPathComponent(UUID().uuidString).appendingPathExtension(fileExtension)
        
        if let filePath = (fileArray.lastObject as? URL)?.path {
            if !fileManager.fileExists(atPath: filePath) {
                try! fileManager.createDirectory(atPath: filePath, withIntermediateDirectories: true, attributes: nil)
            }
        }
        
        return fileURL!
    }

}
