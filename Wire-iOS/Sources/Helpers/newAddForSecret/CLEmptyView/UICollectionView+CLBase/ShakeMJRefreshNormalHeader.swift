

import Foundation
import MJRefresh

class ShakeMJRefreshNormalHeader: MJRefreshNormalHeader {
    override var state: MJRefreshState {
        didSet {
            if state == .pulling {
                WRTools.shake()
            }
        }
    }
}
