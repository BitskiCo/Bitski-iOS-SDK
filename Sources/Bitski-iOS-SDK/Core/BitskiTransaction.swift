//
//  BitskiTransaction.swift
//  Bitski
//
//  Created by Josh Pyles on 3/29/19.
//

import Foundation
import Web3

/// Represents a distinct type of transaction being requested by the app
enum BitskiTransactionKind: Equatable {
    case sendTransaction
    case signTransaction
    case sign
    case signTypedData
    case other(String)
    
    init(methodName: String) {
        switch methodName {
        case "eth_sendTransaction":
            self = .sendTransaction
        case "eth_signTransaction":
            self = .signTransaction
        case "eth_sign":
            self = .sign
        case "eth_signTypedData":
            self = .signTypedData
        default:
            self = .other(methodName)
        }
    }
    
    // Make this private
    private enum RawValues: String, Codable {
        case sendTransaction = "ETH_SEND_TRANSACTION"
        case signTransaction = "ETH_SIGN_TRANSACTION"
        case sign = "ETH_SIGN"
        case signTypedData = "ETH_SIGN_TYPED_DATA"
    }

}

extension BitskiTransactionKind: Codable {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let methodName = try container.decode(String.self)
        self = Self(methodName: methodName)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        switch self {
        case .sendTransaction:
            try container.encode("ETH_SEND_TRANSACTION")
        case .signTransaction:
            try container.encode("ETH_SIGN_TRANSACTION")
        case .sign:
            try container.encode("ETH_SIGN")
        case .signTypedData:
            try container.encode("ETH_SIGN_TYPED_DATA")
        case .other(let method):
            try container.encode(method.uppercased())
        }
    }
}



/// Abstract representation of a transaction to be displayed and approved by the user.
/// This is a custom object that is persisted to the Bitski API, validated, then displayed
/// to the user for approval. Once approved the transaction is processed by the backend, and
/// the result is forwarded back to your app.
///
/// Generic type Payload can be any codable object, but is generally:
///     - EthereumTransactionObject for eth_sendTransaction and eth_signTransaction
///     - MessageSignatureObject for eth_sign / personal_sign / etc
///
struct BitskiTransaction<Payload: Codable>: Codable {
    
    /// Represents additional data about the transaction beyond the payload that is relevant in order to process it
    struct Context: Codable {
        /// The chain id to sign with
        let chainId: Int
        let from: EthereumAddress?
    }
            
    /// A unique id to represent this transaction
    let id: UUID
    
    /// Generic payload object. Represents the data to be processed in the transaction.
    let payload: Payload
    
    /// The kind for this transaction
    let kind: BitskiTransactionKind
    
    /// The context for this transaction
    let context: Context
}

/// Represents the JSON object that is returned by the server
struct BitskiTransactionResponse<T: Codable>: Codable {
    let transaction: BitskiTransaction<T>
}

/// Represents an arbitrary message to be signed
struct MessageSignatureObject: Codable {
    /// The address to sign the message from
    let from: EthereumAddress
    
    /// The message data to be signed
    let message: EthereumData
    
    /// Creates an instance with the given values
    ///
    /// - Parameters:
    ///   - address: The public address to sign the message from
    ///   - message: The message to be signed
    init(from address: EthereumAddress, message: EthereumData) {
        self.from = address
        self.message = message
    }
}

struct TypedDataMessageSignatureObject {
    /// The address to sign the message from
    let from: EthereumAddress
    
    /// The typed data JSON to be signed
    let typedData: String
    
    /// Creates an instance with the given values
    ///
    /// - Parameters:
    ///   - address: The public address to sign the message from
    ///   - message: The message to be signed
    init(from address: EthereumAddress, typedData: String) {
        self.from = address
        self.typedData = typedData
    }
}

extension TypedDataMessageSignatureObject: Codable {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let typedData = try container.decode(JSON.self)
        let typedDataJSONData = try JSONEncoder().encode(typedData)
        self = Self(from: try EthereumAddress.init(hex: "0x0000000000000000000000000000000000000000", eip55: false), typedData: String(data: typedDataJSONData, encoding: .utf8)!)
    }

    func encode(to encoder: Encoder) throws {
        let json = try JSONDecoder().decode(JSON.self, from: self.typedData.data(using: .utf8)!)
        var container = encoder.singleValueContainer()
        try container.encode(json)
    }
}


extension BitskiTransaction {
    
    public init(payload: Payload, kind: BitskiTransactionKind, chainId: Int, id: UUID = UUID(), from: EthereumAddress? = nil) {
        self.init(id: id, payload: payload, kind: kind, context: Context(chainId: chainId, from: from))
    }
    
}
