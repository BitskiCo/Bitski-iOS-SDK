//
//  MockAuthAgent.swift
//  Bitski_Tests
//
//  Created by Josh Pyles on 7/5/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation
import OHHTTPStubs
import AppAuth
@testable import Bitski_iOS_SDK

/// Mock agent that always responds with a valid url
class MockAuthenticationWebSession: AuthorizationSessionProtocol {
    
    required init(url: URL, callbackURLScheme: String?, completionHandler: @escaping (URL?, Error?) -> Void) {
        let code = "a70sWcWyVwEfd8xppJs49hkur-YaMP7P062zjB5EyRE.CNc7HSXtWeaS9KdpaNqMq5ahsdqNsej23kgE5pjohrU"
        let scope = "openid%20offline"
        var state = "SAohQODNQGlbKialz6wwQ0Lv7eCbkhkd9EHF86cEFQs"
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        if let queryItems = components?.queryItems, let requestState = queryItems.first(where: { $0.name == "state" })?.value {
            state = requestState
        }
        let url = URL(string: "bitskiexample://application/callback?code=\(code)&scope=\(scope)&state=\(state)")!
        completionHandler(url, nil)
    }
    
    func start() -> Bool {
        return true
    }
    
    func cancel() {
        
    }
    
}

class MockEmptyURLAuthorizationSession: MockAuthorizationSession {
    required init(url: URL, callbackURLScheme: String?, completionHandler: @escaping (URL?, Error?) -> Void) {
        super.init(url: url, callbackURLScheme: callbackURLScheme, completionHandler: completionHandler)
        let url = URL(string: "example://application/callback")
        result = (url, nil)
    }
}
