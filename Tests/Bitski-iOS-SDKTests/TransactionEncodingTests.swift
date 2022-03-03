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
            let payload = TypedDataMessageSignatureObject(from: try EthereumAddress(hex: "0x0000000000000000000000000000000000000000", eip55: false), typedData: "{\"types\":{}}")
            let transaction = BitskiTransaction(payload: payload, kind: BitskiTransactionKind.init(methodName: "eth_signTypedData"), chainId: 0, id: UUID(uuidString: "0693EA1E-3304-4877-A14B-353DB2D90699")!)
            let json = try JSONEncoder().encode(transaction);
            XCTAssertEqual(String(data: json, encoding: .utf8)!, """
{"id":"0693EA1E-3304-4877-A14B-353DB2D90699","payload":{"types":{}},"kind":"ETH_SIGN_TYPED_DATA","context":{"chainId":0}}
""")
        } catch {
            XCTFail((error as NSError).debugDescription)
        }
    }
    
    func testDecodingTransaction() {
        let json = """
        {
          "clients": [
            {
              "client_id": "8cc43503-9ebd-4588-a77f-51ae160d6934",
              "client_name": "Bitski",
              "client_uri": "bitski://application/callback",
              "logo_uri": "",
              "owner": "8cc43503-9ebd-4588-a77f-51ae160d6934",
              "policy_uri": " bitski://application/callback",
              "tos_uri": " bitski://application/callback"
            }
          ],
          "transaction": {
            "clientId": "8cc43503-9ebd-4588-a77f-51ae160d6934",
            "context": {
              "chainId": 0
            },
            "id": "4e0d94e7-1802-4c5d-aea1-83991477bcfd",
            "kind": "ETH_SIGN",
            "payload": {
              "from": "0xf020b2ae0995acedff07f9fc8298681f5461278a",
              "message": "0x4c6f67696e20746f204175746f67726170682077697468206e6f6e63653a20796d7075476d506e7a446768"
            },
            "submitterId": "b8fbfbfe-0692-4e96-85a7-8833634a4538"
          }
        }
        """;

        do {
            let response = try JSONDecoder().decode(BitskiTransactionResponse<MessageSignatureObject>.self, from: json.data(using: .utf8)!)
        } catch {
            XCTFail((error as NSError).debugDescription)
        }
    }
    
}
