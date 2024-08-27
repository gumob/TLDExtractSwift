//
// Created by Kojiro futamura on 2018-11-17.
//

import Foundation

/// An internal extension for the Bundle class that provides a way to access the current bundle.
/// This is useful for loading resources from the framework's bundle.
internal extension Bundle {
    class ClassForFramework {
    }

    static var current: Bundle {
        return Bundle.init(for: ClassForFramework.self)
    }
}

/// An internal extension for the String class that provides a property to check if the string is a comment.
/// A string is considered a comment if it starts with "//".
internal extension String {
    var isComment: Bool {
        return self.starts(with: "//")
    }
}
