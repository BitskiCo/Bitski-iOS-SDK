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
import SafariServices
@testable import Bitski_iOS_SDK

/// Mock Bitski that injects our mock auth agent
class MockBitski: Bitski {
    
    override init(clientID: String, redirectURL: URL, authorizationClass: AuthorizationSessionProtocol.Type = SFAuthenticationSession.self) {
        super.init(clientID: clientID, redirectURL: redirectURL, authorizationClass: authorizationClass)
        self.providerClass = MockBitskiProvider.self
    }
    
    override func signIn(webView: WKWebView,configuration: OIDServiceConfiguration, agent: OIDExternalUserAgent = BitskiAuthenticationAgent(), additionalParameters: [String: String] = [:], completion: @escaping ((Error?) -> Void)) {
        super.signIn(webView: webView,configuration: configuration, agent: BitskiAuthenticationAgent(authenticationSessionType: MockAuthenticationWebSession.self), additionalParameters: additionalParameters, completion: completion)
    }
}
