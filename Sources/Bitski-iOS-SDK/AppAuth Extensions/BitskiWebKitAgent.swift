//
//  BitskiWebKitAgent.swift
//
//
//  Created by Larry Nguyen on 11/23/21.
//

import Foundation
import WebKit
import AppAuth

class BitskiWebKitAgent: NSObject, OIDExternalUserAgent {
    private let webView: WKWebView
    private var session: OIDExternalUserAgentSession?
    
    init(webView: WKWebView) {
        self.webView = webView
        super.init()
    }
    
    func present(_ request: OIDExternalUserAgentRequest, session: OIDExternalUserAgentSession) -> Bool {
        self.session = session
        
        let request = URLRequest(url: request.externalUserAgentRequestURL())
        webView.load(request)
        return true
    }
    
    func dismiss(animated: Bool, completion: @escaping () -> Void) {
        
        cleanUp()
        completion()
    }
    
        /// Remove references
    private func cleanUp() {
        session = nil
    }
}



