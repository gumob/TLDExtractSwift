//
//  Created by Kojiro futamura on 2018/11/16.
//

import Foundation

#if SWIFT_PACKAGE
import Punycode
#endif

/// PSLParser is responsible for parsing a list of domain names from a given data source.
/// It categorizes the domain names into exceptions, wildcards, and normal entries.
///
/// - Properties:
///   - exceptions: An array of PSLData representing domain names that are exceptions.
///   - wildcards: An array of PSLData representing domain names that are wildcards.
///   - normals: A set of unique domain names that are considered normal entries.
///
/// - Methods:
///   - addLine(_ line: String): Adds a line to the appropriate category based on its content.
///   - parse(data: Data?): Parses the provided data and returns a PSLDataSet containing the categorized domain names.
internal class PSLParser {

    var exceptions: [PSLData] = [PSLData]()
    var wildcards: [PSLData] = [PSLData]()
    var normals = Set<String>()

    /// Adds a line to the appropriate category (wildcards, exceptions, or normals) based on its content.
    /// - Parameter line: A string representing a line from the PSL data.
    internal func addLine(_ line: String) {
        if line.contains("*") {
            self.wildcards.append(PSLData(raw: line))
        } else if line.starts(with: "!") {
            self.exceptions.append(PSLData(raw: line))
        } else if !line.isComment && !line.isEmpty {
            self.normals.insert(line)
        }
    }

    /// Parses the provided data and categorizes the domain names into exceptions, wildcards, and normals.
    /// - Parameter data: The data to be parsed, which should contain PSL entries.
    /// - Throws: TLDExtractError.pslParseError if the data is invalid or cannot be parsed.
    /// - Returns: A PSLDataSet containing the categorized domain names.
    internal func parse(data: Data?) throws -> PSLDataSet {
        guard let data: Data = data, let str: String = String(data: data, encoding: .utf8), str.count > 0 else {
            throw TLDExtractError.pslParseError(message: nil)
        }

        str.components(separatedBy: .newlines).forEach { [weak self] (line: String) in
            if line.isComment {
                return
            }
            if line.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                return
            }

            self?.addLine(line)

            // this does the same thing as update-psl.py
            #if SWIFT_PACKAGE
            if let encoded = line.idnaEncoded {
                self?.addLine(encoded)
            }
            #endif
        }
        return PSLDataSet(
            exceptions: exceptions,
            wildcards: wildcards,
            normals: normals
        )
    }
}

/// A class responsible for parsing top-level domains (TLDs) from a given PSLDataSet.
/// It provides methods to parse exceptions, wildcards, and normal domains from host strings.
internal class TLDParser {

    private let pslDataSet: PSLDataSet

    internal init(dataSet: PSLDataSet) {
        self.pslDataSet = dataSet
    }

    /// Parses exceptions and wildcards for a given host string.
    /// - Parameter host: The host string to be parsed.
    /// - Returns: An optional TLDResult containing the parsed components if a match is found.
    internal func parseExceptionsAndWildcards(host: String) -> TLDResult? {
        let hostComponents: [String] = host.lowercased().components(separatedBy: ".")
        /// Search exceptions first, then search wildcards if not match
        let matchClosure: (PSLData) -> Bool = { $0.matches(hostComponents: hostComponents) }
        let pslData: PSLData? = self.pslDataSet.exceptions.first(where: matchClosure) ?? self.pslDataSet.wildcards.first(where: matchClosure)
        return pslData?.parse(hostComponents: hostComponents)
    }

    /// Parses normal domains from a given host string.
    /// - Parameter host: The host string to be parsed.
    /// - Returns: An optional TLDResult containing the parsed components if a match is found.
    internal func parseNormals(host: String) -> TLDResult? {
        let tldSet: Set<String> = self.pslDataSet.normals
        /// Split the hostname to components
        let hostComponents = host.lowercased().components(separatedBy: ".")
        /// A host must have at least two parts else it's a TLD
        guard hostComponents.count >= 2 else { return nil }
        /// Iterate from lower level domain and check if the hostname matches a suffix in the dataset
        var copiedHostComponents: ArraySlice<String> = ArraySlice(hostComponents)
        var topLevelDomain: String?
        repeat {
            guard !copiedHostComponents.isEmpty else { return nil }
            topLevelDomain = copiedHostComponents.joined(separator: ".")
            copiedHostComponents = copiedHostComponents.dropFirst()
        } while !tldSet.contains(topLevelDomain ?? "")

        if topLevelDomain == host { topLevelDomain = nil }

        /// Extract the host name to each level domain
        let rootDomainRange: Range<Int> = (copiedHostComponents.startIndex - 2)..<hostComponents.endIndex
        let rootDomain: String? = rootDomainRange.startIndex >= 0 ? hostComponents[rootDomainRange].joined(separator: ".") : nil

        let secondDomainRange: Range<Int> = (rootDomainRange.lowerBound)..<(rootDomainRange.lowerBound + 1)
        let secondDomain: String? = secondDomainRange.startIndex >= 0 ? hostComponents[secondDomainRange].joined(separator: ".") : nil

        let subDomainRange: Range<Int> = (hostComponents.startIndex)..<(max(secondDomainRange.lowerBound, hostComponents.startIndex))
        let subDomain: String? = subDomainRange.endIndex >= 1 ? hostComponents[subDomainRange].joined(separator: ".") : nil

        return TLDResult(
            rootDomain: rootDomain,
            topLevelDomain: topLevelDomain,
            secondLevelDomain: secondDomain,
            subDomain: subDomain
        )
    }
}
