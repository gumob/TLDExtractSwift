//
// Created by Kojiro futamura on 2018-11-17.
//

import Foundation

/// TLDExtractError represents errors that can occur in TLDExtract.
/// - pslParseError: Indicates an error that occurred while parsing PSL data.
enum TLDExtractError: Error {
    case pslParseError(message: Error?)
}
