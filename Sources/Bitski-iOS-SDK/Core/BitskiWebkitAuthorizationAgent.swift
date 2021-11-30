//
//  BitskiWebkitAuthorizationAgent.swift
//  
//
//  Created by Larry Nguyen on 11/30/21.
//

import Foundation
import WebKit
import AuthenticationServices
import PromiseKit

extension ASWebAuthenticationSession: AuthorizationSessionProtocol{}

class BitskiWebkitAuthorizationAgent {
    var baseURL: URL
    var redirectURL: URL
    
    enum Error: Swift.Error {
        case invalidRequest
        case missingData
    }
    var authorizationSessionType: AuthorizationSessionProtocol.Type

    
    private var currentSession: AuthorizationSessionProtocol?

    init(baseURL: URL, redirectURL: URL, authorizationClass: AuthorizationSessionProtocol.Type = ASWebAuthenticationSession.self) {
        self.baseURL = baseURL
        self.redirectURL = redirectURL
        self.authorizationSessionType = authorizationClass
    }
    
    
    func requestAuthorization(transactionId: String) -> Promise<Data> {
        guard let url = self.urlForTransaction(transactionId: transactionId, baseURL: baseURL) else {
            return Promise(error: Error.invalidRequest)
        }
        return firstly {
            sendViaWeb(url: url)
        }.map { url in
            try self.parseResponse(url: url)
        }
    }
    
    private func sendViaWeb(url: URL) -> Promise<URL> {
        return Promise { resolver in
                // UI work must happen on the main queue, rather than our internal queue
            DispatchQueue.main.async {
                    //todo: ideally find a way to do this without relying on SFAuthenticationSession.
                self.currentSession = self.authorizationSessionType.init(url: url, callbackURLScheme: self.redirectURL.scheme) { url, error in
                    defer {
                        self.currentSession = nil
                    }
                    
                    if let url = url {
                        return resolver.fulfill(url)
                    }
                    
                    if let error = error {
                        return resolver.reject(error)
                    }
                    
                    resolver.reject(Error.missingData)
                }
                self.currentSession?.start()
            }
        }
    }
    
    /// Parse a response from the web using URL query items
    ///
    /// - Parameter url: Callback URL with result
    /// - Returns: Web3Response with either the result if it can successfully be decoded from the query params, or an error
    /// - Throws: BitskiAuthorizationAgent.Error when data cannot be retrieved from the provided url
    private func parseResponse(url: URL) throws -> Data {
        let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true)
        
        guard let data = urlComponents?.queryItems?.filter( { (item) -> Bool in
            item.name == "result"
        }).compactMap({ (queryItem) -> Data? in
            return queryItem.value.flatMap { Data(base64Encoded: $0) }
        }).first else {
            throw Error.missingData
        }
        
        return data
    }
    
    /// Generates the web url for the transaction
    ///
    /// - Parameters:
    ///   - transactionId: transaction id
    ///   - baseURL: url for the website to build against
    /// - Returns: A URL for the transaction, if one could be generated
    private func urlForTransaction(transactionId: String, baseURL: URL) -> URL? {
        var urlString = "/transactions/\(transactionId)"
        if let encodedRedirectURI = redirectURL.absoluteString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            urlString += "?redirectURI=\(encodedRedirectURI)"
        }
        return URL(string: urlString, relativeTo: baseURL)
    }
    
}
