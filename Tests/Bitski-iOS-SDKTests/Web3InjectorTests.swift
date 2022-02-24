//
//  File.swift
//  
//
//  Created by Patrick Tescher on 2/23/22.
//

import XCTest
import Web3
import PromiseKit
import OHHTTPStubs
@testable import Bitski_iOS_SDK
import WebKit

class Web3InjectorTests: XCTestCase {
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

    func testWeb3Injection() {
        BitskiTestStubs.stubTransactionAPI()
        let signer = StubbedTransactionSigner()
        signer.injectedSignResponse = EthereumValue.string("0xa3f20717a250c2b0b729b7e5becbff67fdaef7e0699da4de7ca5895b02a170a12d887fd3b17bfdce3481f10bea41f45ba9f709d39ce8325427b57afcfc994cee1b")
        let provider = createTestProvider(signer: signer)
        let web3 = Web3(provider: provider)

        let webViewConfiguration = WKWebViewConfiguration();
        webViewConfiguration.preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")

        
        let bridge = WebViewWeb3Bridge(web3: web3);
        try! bridge.injectWeb3(webViewConfiguration.userContentController)

        let promise = expectation(description: "Bridge should observe")
        bridge.observer = { message in
            if (message.body as? [String: Any])?["msg"] as? [String] == ["0xa3f20717a250c2b0b729b7e5becbff67fdaef7e0699da4de7ca5895b02a170a12d887fd3b17bfdce3481f10bea41f45ba9f709d39ce8325427b57afcfc994cee1b"] {
                promise.fulfill()
            } else {
                print(message.body)
            }
        }

        let webView = WKWebView(frame: CGRect(x: 0, y: 0, width: 320, height: 480), configuration: webViewConfiguration)
        
        let testHTML: String = """
            <!DOCTYPE html>
            <html lang="en">
              <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <meta http-equiv="X-UA-Compatible" content="ie=edge">
                <title>Test Web3</title>
              </head>
              <body>
                <script>
                    setTimeout(function(){
                        window.ethereum.request({method: "eth_sign", params: ["0x9F2c4Ea0506EeAb4e4Dc634C1e1F4Be71D0d7531", "0xdeadbeaf"]}).then(console.log).catch(console.error);
                    },1000);
                </script>
              </body>
            </html>
        """;
        
        webView.loadHTMLString(testHTML, baseURL: nil)
        
        print(webViewConfiguration.userContentController.userScripts)
        
        waitForExpectations(timeout: 10)
    }
}
