
protocol AlertResultConfiguration {
    static var title: String { get }
    static var all: [Self] { get }
    func action(_ handler: @escaping (Self) -> Void) -> UIAlertAction
}

extension AlertResultConfiguration {
    static func controller(_ handler: @escaping (Self) -> Void) -> UIAlertController {
        let controller = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
        all.map { $0.action(handler) }.forEach(controller.addAction)
        controller.applyTheme()
        return controller
    }
}

extension GroupDetailsViewController {
    func request<T: AlertResultConfiguration>(_ result: T.Type, handler: @escaping (T) -> Void) {
        present(result.controller(handler))
    }
}

extension ConversationActionController {
    
    func request<T: AlertResultConfiguration>(_ result: T.Type, handler: @escaping (T) -> Void) {
        present(result.controller(handler))
    }
    
}
