import Foundation

/// ShowableError protocol - defining how class adopting should be resented in alert view
protocol ShowableError: Error {
    func alertTitle() -> String?
    func alertBody() -> String
}

// MARK: Common Error
enum CommonError : Error {
    case unknownError
    case notEnoughData
    case userCancelled
    case operationFailed
    case serializationError
    case other(Error)
    case failure(reason: String)
}

extension CommonError: ShowableError {
    
    func alertTitle() -> String? {
        switch self {
        case .other(let otherError) where otherError is ShowableError:
            return (otherError as! ShowableError).alertTitle()
            
        default:
            return nil
        }
    }
    
    func alertBody() -> String {
        switch self {
        case .serializationError:
            return NSLocalizedString("Serialization error", comment: "Serialization error")
        
        case .other(let otherError) where otherError is ShowableError:
            return (otherError as! ShowableError).alertBody()
            
        case .other(let otherError):
            return "\((otherError as NSError).localizedDescription)"
            
        case .unknownError:
            return NSLocalizedString("Unknown error occured!", comment: "Unknown error occured!")
            
        case .failure(reason: let reason):
            return reason
            
        default:
            return "\(self)"
        }
    }
    
}
