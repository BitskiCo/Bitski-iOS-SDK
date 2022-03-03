//
//  TransactionEncodingTests.swift
//  
//
//  Created by Patrick Tescher on 3/3/22.
//

import XCTest
import Web3
import PromiseKit
import OHHTTPStubs
@testable import Bitski_iOS_SDK

class TransactionEncodingTests: XCTestCase {
    func testEncodingEthSignTypedData() {
        do {
            let payload = TypedDataMessageSignatureObject(from: try EthereumAddress(hex: "0x0000000000000000000000000000000000000000", eip55: false), typedData: "{}")
            let transaction = BitskiTransaction(payload: payload, kind: BitskiTransactionKind.init(methodName: "eth_signTypedData"), chainId: 0, id: UUID(uuidString: "0693EA1E-3304-4877-A14B-353DB2D90699")!)
            let json = try JSONEncoder().encode(transaction);
            XCTAssertEqual(String(data: json, encoding: .utf8)!, """
{"id":"0693EA1E-3304-4877-A14B-353DB2D90699","payload":{"typedData":"{}","from":"0x0000000000000000000000000000000000000000"},"kind":"ETH_SIGN_TYPED_DATA","context":{"chainId":0}}
""")
        } catch {
            XCTFail((error as NSError).debugDescription)
        }
    }
    
}
