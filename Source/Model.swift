//
// Created by kojirof on 2018-11-17.
// Copyright (c) 2018 Gumob. All rights reserved.
//

import Foundation

internal struct PSLDataSet {
    let exceptions: [PSLData]
    let wildcards: [PSLData]
    let normals: Set<String>
}

internal struct PSLData {
    /// The flag that indicates data is exception
    let isException: Bool
    /// TLD Parts split by dot
    /// e.g. ["*", "yokohama", "jp"]
    let tldParts: [PSLDataPart]
    /// The priority score to sort the dataset
    /// If the hostname matches more than one rule, the one which has the highest priority is prevailing
    let priority: Int

    init(raw: String) {
        self.isException = raw.starts(with: "!")
        let tldStr: String = self.isException ? String(raw.dropFirst()) : raw
        self.tldParts = tldStr.components(separatedBy: ".").map(PSLDataPart.init)
        self.priority = (self.isException ? 1000 : 0) + self.tldParts.count
    }
}

extension PSLData {
    ///
    /// For more information about the public suffix list,
    /// See the 'Definitions' section at https://publicsuffix.org/list/
    ///
    /// A domain is said to match a rule if and only if all of the following conditions are met:
    /// - When the domain and rule are split into corresponding labels,
    ///     that the domain contains as many or more labels than the rule.
    /// - Beginning with the right-most labels of both the domain and the rule,
    ///     and continuing for all labels in the rule, one finds that for every pair,
    ///     either they are identical, or that the label from the rule is "*".
    ///
    func matches(hostComponents: [String]) -> Bool {
        /// The host must have at least as many components as the TLD
        let delta: Int = hostComponents.count - self.tldParts.count
        guard delta >= 0 else { return false }

        /// Drop extra components from the host components so that two arrays have the same size
        let droppedHostComponents = hostComponents.dropFirst(delta)

        /// Find the PSLDataPart that matches the host component
        let zipped: Zip2Sequence<[PSLDataPart], ArraySlice<String>> = zip(self.tldParts, droppedHostComponents)
        return zipped.allSatisfy { (pslData: PSLDataPart, hostComponent: String) in
            return pslData.matches(component: hostComponent)
        }
    }

    func parse(hostComponents: [String]) -> TLDResult {
        let partsCount: Int = tldParts.count - (self.isException ? 1 : 0)
        let delta: Int = hostComponents.count - partsCount

        /// Extract the host name to each level domain
        let topLevelDomain: String? = delta == 0 ? nil : hostComponents.dropFirst(delta).joined(separator: ".")
        let rootDomain: String? = delta == 0 ? nil : hostComponents.dropFirst(delta - 1).joined(separator: ".")
        let secondDomain: String? = delta == 0 ? nil : hostComponents[delta - 1]
        let subDomain: String? = delta < 2 ? nil : hostComponents.prefix(delta - 1).joined(separator: ".")

        return TLDResult(rootDomain: rootDomain,
                         topLevelDomain: topLevelDomain,
                         secondLevelDomain: secondDomain,
                         subDomain: subDomain)
    }
}

extension PSLData: Comparable {
    static func < (lhs: PSLData, rhs: PSLData) -> Bool {
        return lhs.priority < rhs.priority
    }

    static func == (lhs: PSLData, rhs: PSLData) -> Bool {
        return lhs.priority == rhs.priority
    }
}

internal enum PSLDataPart {
    ///
    /// For more information about the wildcard character,
    /// See the 'Specification' section at https://publicsuffix.org/list/
    ///
    /// The wildcard character * (asterisk) matches any valid sequence of characters in a hostname part.
    /// Wildcards are not restricted to appear only in the leftmost position,
    /// but they must wildcard an entire label. (I.e. *.*.foo is a valid rule: *bar.foo is not.)
    ///
    case wildcard
    case characters(String)

    init(component: String) {
        self = component == "*" ? .wildcard : .characters(component)
    }

    func matches(component: String) -> Bool {
        switch self {
        case .wildcard:
            return true
        case let .characters(str):
            return str == component
        }
    }
}
