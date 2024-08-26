//
// Created by Kojiro futamura on 2018-11-17.
//

import Foundation

internal extension Bundle {
    class ClassForFramework {
    }

    static var current: Bundle {
        return Bundle.init(for: ClassForFramework.self)
    }
}

internal extension String {
    var isComment: Bool {
        return self.starts(with: "//")
    }
}
