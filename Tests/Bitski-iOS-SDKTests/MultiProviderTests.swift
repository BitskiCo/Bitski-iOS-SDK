//
//  File.swift
//  
//
//  Created by Patrick Tescher on 2/24/22.
//

import XCTest
import Web3
import OHHTTPStubs
@testable import Bitski_iOS_SDK

class BitskiMultiProviderTests: XCTestCase {
    
    private var authDelegate: BitskiAuthDelegate?
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        //OHHTTPStubs.removeAllStubs()
        authDelegate = nil
    }
    
    func createTestProvider(isLoggedIn: Bool = true, signer: TransactionSigner? = nil) -> BitskiHTTPProvider {
        let authDelegate =  MockAuthDelegate()
        // Retain auth delegate
        self.authDelegate = authDelegate
        authDelegate.isLoggedIn = isLoggedIn
        let signer = signer ?? TransactionSigner(apiBaseURL: URL(string: "https://api.bitski.com/v1/")!, webBaseURL: URL(string: "https://sign.bitski.com")!, redirectURL: URL(string: "bitskiexample://application/callback")!)
        let provider = BitskiHTTPProvider(rpcURL: URL(string: "https://api.bitski.com/v1/web3/kovan")!, network: .kovan, signer: signer)
        provider.authDelegate = authDelegate
        signer.authDelegate = authDelegate
        return provider
    }
    
    func testMultiProvider() {
        let httpProvider = Web3HttpProvider(rpcURL: "https://api.bitski.com/v1/web3/mainnet")
        let localProvider = LocalProvider(httpProvider: httpProvider, addresses: [try! EthereumAddress.init(hex: "0xf020b2AE0995ACeDFf07f9FC8298681f5461278A", eip55: false)])
        
        BitskiTestStubs.stubAccounts()
        let bitskiProvider = createTestProvider()

        let multiProvider = MultiProvider([localProvider, bitskiProvider])
        
        let web3 = Web3(provider: multiProvider)
        
        let expectation = self.expectation(description: "Should get accounts")
        web3.eth.accounts { accounts in
            expectation.fulfill()
            XCTAssertEqual(accounts.result?.count, 2)
        }
        
        waitForExpectations(timeout: 10)
    }

}
