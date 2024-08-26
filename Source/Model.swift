//
// Created by Kojiro futamura on 2018-11-17.
//

import Foundation

/// A structure that represents a dataset of Public Suffix List (PSL) entries.
/// It categorizes the entries into exceptions, wildcards, and normal domain names.
///
/// - Properties:
///   - exceptions: An array of PSLData representing domain names that are exceptions.
///   - wildcards: An array of PSLData representing domain names that are wildcards.
///   - normals: A set of unique domain names that are considered normal entries.
internal struct PSLDataSet {
    let exceptions: [PSLData]
    let wildcards: [PSLData]
    let normals: Set<String>
}

/// A structure that represents a Public Suffix List (PSL) data entry.
/// It contains information about whether the entry is an exception, 
/// the parts of the top-level domain (TLD) split by dots, and the priority score.
///
/// - Properties:
///   - isException: A Boolean flag indicating if the data entry is an exception.
///   - tldParts: An array of PSLDataPart representing the TLD parts split by dots.
///   - priority: An integer representing the priority score to sort the dataset.
///     If the hostname matches more than one rule, the one with the highest priority prevails.
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

/// An extension of `PSLData` that provides functionality to match domain components
/// against the Public Suffix List (PSL) rules and to parse the components of a domain.
///
/// This extension includes methods to determine if a domain matches a given PSL rule
/// and to extract the various components of the domain such as root domain, top-level domain,
/// second-level domain, and subdomain.
///
/// - Methods:
///   - matches(hostComponents: [String]) -> Bool: Checks if the provided host components
///     match the PSL rule represented by this `PSLData`.
///   - parse(hostComponents: [String]) -> TLDResult: Parses the provided host components
///     and returns a `TLDResult` containing the extracted domain components.
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

        return TLDResult(
            rootDomain: rootDomain,
            topLevelDomain: topLevelDomain,
            secondLevelDomain: secondDomain,
            subDomain: subDomain
        )
    }
}

/// An extension of `PSLData` that conforms to the `Comparable` protocol.
/// This allows `PSLData` instances to be compared based on their priority.
///
/// - Parameters:
///   - lhs: The left-hand side `PSLData` instance to compare.
///   - rhs: The right-hand side `PSLData` instance to compare.
///
/// - Returns: A Boolean value indicating whether the left-hand side instance has a lower priority than the right-hand side instance.
extension PSLData: Comparable {
    static func < (lhs: PSLData, rhs: PSLData) -> Bool {
        return lhs.priority < rhs.priority
    }

    /// Checks if two `PSLData` instances are equal based on their priority.
    ///
    /// - Parameters:
    ///   - lhs: The left-hand side `PSLData` instance to compare.
    ///   - rhs: The right-hand side `PSLData` instance to compare.
    ///
    /// - Returns: A Boolean value indicating whether the two instances have the same priority.
    static func == (lhs: PSLData, rhs: PSLData) -> Bool {
        return lhs.priority == rhs.priority
    }
}

/// An enumeration representing parts of a Public Suffix List (PSL) data entry.
/// 
/// This enum categorizes the components of a domain name into two types:
/// - `wildcard`: Represents a wildcard character that can match any valid sequence of characters in a hostname part.
/// - `characters(String)`: Represents a specific sequence of characters in a hostname part.
///
/// For more information about the wildcard character,
/// check the 'Specification' section at https://publicsuffix.org/list/
///
/// The wildcard character * (asterisk) matches any valid sequence of characters in a hostname part.
/// Wildcards are not restricted to appear only in the leftmost position,
/// but they must wildcard an entire label. (I.e. *.*.foo is a valid rule: *bar.foo is not.)
internal enum PSLDataPart {
    case wildcard
    case characters(String)

    init(component: String) {
        self = component == "*" ? .wildcard : .characters(component)
    }

    /// Checks if the given component matches this PSLDataPart.
    /// - Parameter component: The hostname part to check against.
    /// - Returns: A Boolean value indicating whether the component matches.
    func matches(component: String) -> Bool {
        switch self {
        case .wildcard:
            return true
        case let .characters(str):
            return str == component
        }
    }
}
