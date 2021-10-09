

extension UIAlertController {
    
    convenience init(forNewSelfClients clients: Set<UserClient>) {
        var deviceNamesAndDates: [String] = []
        
        for userClient in clients {
            let deviceName: String
            
            if let model = userClient.model,
                model.isEmpty == false {
                deviceName = model
            } else {
                deviceName = userClient.type.rawValue
            }
            
            let formatKey = "registration.devices.activated".localized
            let formattedDate = userClient.activationDate?.formattedDate
            let deviceDate = String(format: formatKey, formattedDate ?? "")
            
            deviceNamesAndDates.append("\(deviceName)\n\(deviceDate)")
        }
        
        let title = "self.new_device_alert.title".localized
        
        let messageFormat = clients.count > 1 ? "self.new_device_alert.message_plural".localized : "self.new_device_alert.message".localized
        
        let message = String(format: messageFormat, deviceNamesAndDates.joined(separator: "\n\n"))
        
        self.init(title: title, message: message, preferredStyle: .alert)
    }
}

