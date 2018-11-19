//
// Created by kojirof on 2018-11-17.
// Copyright (c) 2018 Gumob. All rights reserved.
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
