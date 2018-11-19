//
//  TLDExtract.swift
//  TLDExtract
//
//  Created by kojirof on 2018/11/16.
//  Copyright © 2018 Gumob. All rights reserved.
//

import Foundation

public class TLDExtract {

    private let tldParser: TLDParser

    public init(useFrozenData: Bool = false) throws {
        let url = Bundle.current.url(
                forResource: useFrozenData ? "public_suffix_list_frozen" : "public_suffix_list",
                withExtension: "dat")!
        let data: Data = try Data(contentsOf: url)
        let dataSet = try PSLParser().parse(data: data)
        self.tldParser = TLDParser(dataSet: dataSet)
    }

    /// Parameters:
    ///   - host: Hostname to be extracted
    ///   - quick: If true, parse only normal data excluding exceptions and wildcards
    public func parse(host: String, quick: Bool = false) -> TLDResult? {
        if quick {
            return self.tldParser.parseNormals(host: host)
        } else {
            return self.tldParser.parseExceptionsAndWildcards(host: host) ??
                   self.tldParser.parseNormals(host: host)
        }
    }

}

public struct TLDResult {
    public let rootDomain: String?
    public let topLevelDomain: String?
    public let secondLevelDomain: String?
    public let subDomain: String?
}
