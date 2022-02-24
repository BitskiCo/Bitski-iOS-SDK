//
//  File.swift
//  
//
//  Created by Patrick Tescher on 2/24/22.
//

import Web3
import Dispatch
import Foundation

public class MultiProvider: Web3Provider {
    public func send<Params, Result>(request: RPCRequest<Params>, response: @escaping Web3ResponseCompletion<Result>) where Params : Decodable, Params : Encodable, Result : Decodable, Result : Encodable {
        Self.send(providers: self.subProviders, request: request, response: response)
    }
    
    class func send<Params, Result>(providers: [Web3Provider], request: RPCRequest<Params>, response: @escaping Web3ResponseCompletion<Result>) where Params : Decodable, Params : Encodable, Result : Decodable, Result : Encodable {
        var providers = providers
        
        if request.method == "eth_accounts" {
            return self.allAccounts(requestId: request.id, providers: providers, response: response)
        }
        
        if providers.count == 1 {
            providers[0].send(request: request, response: response)
            return
        }
        
        guard let account = Self.account(for: request) else {
            providers.first?.send(request: request, response: response)
            return
        }
        
        if providers.count > 0 {
            let nextProvider = providers.removeFirst();
            Self.accounts(provider: nextProvider) { accounts in
                if let accounts = accounts.result, accounts.contains(account) {
                    nextProvider.send(request: request, response: response)
                } else {
                    Self.send(providers: providers, request: request, response: response)
                }
            }
        }
    }

    
    private var subProviders: [Web3Provider]
    
    init(_ subProviders: [Web3Provider]) {
        self.subProviders = subProviders
    }
    
    class func account<Request>(for: RPCRequest<Request>) -> EthereumAddress? {
        return nil
    }
    
    internal class func allAccounts<Result>(requestId: Int, providers: [Web3Provider], response: @escaping Web3ResponseCompletion<Result>) {
        let dispatchGroup = DispatchGroup()

        var results: [EthereumAddress] = [];
        for provider in providers {
            dispatchGroup.enter()
            Self.accounts(provider: provider) { resp in
                if let result = resp.result {
                    results.append(contentsOf: result)
                }
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: DispatchQueue.main, execute: {
            Self.accountsReponse(requstId: requestId, accounts: results, response: response)
        })

    }
    
    class func accounts(provider: Web3Provider, response: @escaping Web3ResponseCompletion<[EthereumAddress]>) {
        let req = BasicRPCRequest(id: 1, jsonrpc: Web3.jsonrpc, method: "eth_accounts", params: [])

        provider.send(request: req, response: response)
    }
    
    class func accountsReponse<Result>(requstId: Int, accounts: [EthereumAddress], response callback: @escaping Web3ResponseCompletion<Result>) {
        let stringAddresses = accounts.map { address in
            address.hex(eip55: false)
        }
        let resultJSON = String(data: (try! JSONSerialization.data(withJSONObject: stringAddresses, options: [])), encoding: .utf8)!
        let responseJSON = """
        {
            "id": \(requstId),
            "jsonrpc": "2.0",
            "result": \(resultJSON)
        }
        """

        let response: RPCResponse<Result> = try! JSONDecoder().decode(RPCResponse<Result>.self, from: responseJSON.data(using: .utf8)!)
        let web3Response: Web3Response<Result> = Web3Response(rpcResponse: response )
        callback(web3Response)
    }
}
