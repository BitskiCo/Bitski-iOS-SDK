//
//  MockBitski.swift
//  Bitski_Tests
//
//  Created by Josh Pyles on 7/5/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation
import AppAuth
import WebKit
@testable import Bitski_iOS_SDK

/// Mock Bitski that injects our mock auth agent
class MockBitski: Bitski {
    
    override init(clientID: String, redirectURL: URL) {
        super.init(clientID: clientID, redirectURL: redirectURL)
        self.providerClass = MockBitskiProvider.self
    }
    
    override func signIn(webView: WKWebView,configuration: OIDServiceConfiguration, agent: OIDExternalUserAgent = BitskiAuthenticationAgent(), completion: @escaping ((Error?) -> Void)) {
        super.signIn(webView: webView,configuration: configuration, agent: BitskiAuthenticationAgent(authenticationSessionType: MockAuthenticationWebSession.self), completion: completion)
    }
}
