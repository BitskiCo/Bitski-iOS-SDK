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
    
    func testDecoding() {
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
    "id": "2b3096d6-065d-40c9-9053-120f568a0206",
    "kind": "ETH_SIGN_TYPED_DATA",
    "payload": {
      "from": "0xf020b2ae0995acedff07f9fc8298681f5461278a",
      "typedData": "{\\"domain\\":{\\"chainId\\":1,\\"name\\":\\"Collab.Land Connect\\",\\"verifyingContract\\":\\"0xCcCCccccCCCCcCCCCCCcCcCccCcCCCcCcccccccC\\",\\"version\\":\\"1\\"},\\"primaryType\\":\\"Verify\\",\\"message\\":{\\"message\\":\\"Verify account ownership\\"},\\"types\\":{\\"EIP712Domain\\":[{\\"name\\":\\"name\\",\\"type\\":\\"string\\"},{\\"name\\":\\"version\\",\\"type\\":\\"string\\"},{\\"name\\":\\"chainId\\",\\"type\\":\\"uint256\\"},{\\"name\\":\\"verifyingContract\\",\\"type\\":\\"address\\"}],\\"Verify\\":[{\\"name\\":\\"message\\",\\"type\\":\\"string\\"}]}}"
    },
    "submitterId": "b8fbfbfe-0692-4e96-85a7-8833634a4538"
  }
}
"""
        
        let decoded = try! JSONDecoder().decode(BitskiTransactionResponse<TypedDataMessageSignatureObject>.self, from: json.data(using: .utf8)!)
    }
    
}
