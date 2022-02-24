//
//  File.swift
//  
//
//  Created by Patrick Tescher on 2/23/22.
//

import Foundation
import WebKit
import Web3

class WebViewWeb3Bridge: NSObject, WKScriptMessageHandler {
    var observer: ((_ message: WKScriptMessage) -> Void)?
    var web3: Web3
    
    init(web3: Web3) {
        self.web3 = web3
    }

    func userContentController(_ userContentController: WKUserContentController,
                               didReceive message: WKScriptMessage) {
        if (message.name == "web3") {
            self.handleWeb3Request(message, for: message.webView)
        } else {
            observer?(message)
        }
    }
    
    func handleWeb3Request(_ message: WKScriptMessage, for webView: WKWebView?) {
        let requestString = message.body as? String ?? ""
        do {
            let request = try JSONDecoder().decode(BasicRPCRequest.self, from: requestString.data(using: .utf8)!)
            
            let id = request.id;
            
            let responseHandler: Web3.Web3ResponseCompletion<EthereumValue> = { (resp) in
                guard let webView = webView else { return }
                
                do {
                    let resultString = try resp.result.flatMap { result in
                        guard let result = result.string else { throw NSError(domain: "com.bitski", code: 500, userInfo: [NSLocalizedDescriptionKey: "Invalid response type"]) }
                        return String(data: try JSONSerialization.data(withJSONObject: result, options: [.fragmentsAllowed]), encoding: .utf8)!
                    } ?? "null"
                    
                    let errorString = try resp.error.flatMap { error in
                        return String(data: try JSONSerialization.data(withJSONObject: error.localizedDescription, options: [.fragmentsAllowed]), encoding: .utf8)!
                    } ?? "null"

                    let script = "window.ethereum.handleCallback(\(id), \(resultString), \(errorString))"
                    
                    print(script)
                    
                    webView.evaluateJavaScript(script) { (result, error) in
                        if let result = result {
                            print("Label is updated with message: \(result)")
                        } else if let error = error {
                            print("An error occurred: \(error)")
                        }
                    }

                } catch {
                    print(error)
                }

            }
            
            web3.provider.send(request: request, response: responseHandler)
        } catch {
            print("Could not decode request: \(message.body) \(error)")
        }
    }

    func injectWeb3(_ controller: WKUserContentController) throws {
        let bundle = Bundle.module
        let jsFileURL = bundle.url(forResource: "BitskiWeb3Provider", withExtension: "js")!
        let js = try String(contentsOf: jsFileURL)
        let userScript = WKUserScript(source: js,
                                      injectionTime: WKUserScriptInjectionTime.atDocumentEnd,
                                      forMainFrameOnly: true)
        
        controller.addUserScript(userScript)
        controller.add(self, name: "web3")
        
        let source = """
        function format(...args) { return args; }
        function captureLog(str, ...args) { var msg = format(str, ...args); window.webkit.messageHandlers.logHandler.postMessage({ msg, level: 'log' }); }
        function captureWarn(str, ...args) { var msg = format(str, ...args); window.webkit.messageHandlers.logHandler.postMessage({ msg, level: 'warn' }); }
        function captureError(str, ...args) { var msg = format(str, ...args); window.webkit.messageHandlers.logHandler.postMessage({ msg, level: 'error' }); }
        window.console.error = captureError; window.console.warn = captureWarn;
        window.console.log = captureLog; window.console.debug = captureLog; window.console.info = captureLog;
        window.onerror = window.webkit.messageHandlers.errorHandler.postMessage;
        """
        
        let script = WKUserScript(source: source, injectionTime: .atDocumentStart, forMainFrameOnly: false)
        controller.addUserScript(script)
        controller.add(self, name: "logHandler")
    }
}


extension String {
    func escapeString() -> String {
        var newString = self.replacingOccurrences(of: "\"", with: "\"\"")
        if newString.contains(",") || newString.contains("\n") {
            newString = String(format: "\"%@\"", newString)
        }

        return newString
    }
}
