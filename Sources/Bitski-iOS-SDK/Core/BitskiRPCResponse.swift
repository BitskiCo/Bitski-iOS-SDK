//
//  BitskiRPCResponse.swift
//  
//
//  Created by Larry Nguyen on 4/29/22.
//

import Foundation

public struct BitskiRPCResponse<Result: Codable>: Codable {

    /// The rpc id
    public let id: String

    /// The jsonrpc version. Typically 2.0
    public let jsonrpc: String

    /// The result
    public let result: Result?

    /// The error
    public let error: Error?

    public struct Error: Swift.Error, Codable {

        /// The error code
        public let code: Int

        /// The error message
        public let message: String
        
        /// Description
        public var localizedDescription: String {
            return "RPC Error (\(code)) \(message)"
        }
    }
}
