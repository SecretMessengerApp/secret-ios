
import Foundation

extension ProcessInfo {
    
    var isRunningTests : Bool {
        return environment["XCTestConfigurationFilePath"] != nil
    }
    
}
