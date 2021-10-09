

public enum BaseResult<S, F> {
    case success(S)
    case failure(F)
}

extension BaseResult where S == Void {
    static var success: BaseResult {
        return .success(())
    }
}
