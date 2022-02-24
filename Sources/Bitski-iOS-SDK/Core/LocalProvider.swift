//
//  File.swift
//  
//
//  Created by Patrick Tescher on 2/24/22.
//

import Web3
import Foundation

public class LocalProvider: Web3Provider {
    let httpProvider: Web3HttpProvider
    let addresses: [EthereumAddress]
    
    init(httpProvider: Web3HttpProvider, addresses: [EthereumAddress]) {
        self.httpProvider = httpProvider
        self.addresses = addresses
    }
    
    public func send<Params, Result>(request: RPCRequest<Params>, response: @escaping Web3ResponseCompletion<Result>) where Params : Decodable, Params : Encodable, Result : Decodable, Result : Encodable {
        switch request.method {
        case "eth_accounts":
            self.accounts(requestId: request.id, response: response)
        default:
            self.httpProvider.send(request: request, response: response)
        }
    }
    
    func accounts<Result>(requestId: Int, response callback: @escaping Web3ResponseCompletion<Result>) {
        let stringAddresses = self.addresses.map { address in
            address.hex(eip55: false)
        }
        let resultJSON = String(data: (try! JSONSerialization.data(withJSONObject: stringAddresses, options: [])), encoding: .utf8)!
        let responseJSON = """
        {
            "id": \(requestId),
            "jsonrpc": "2.0",
            "result": \(resultJSON)
        }
        """

        let response: RPCResponse<Result> = try! JSONDecoder().decode(RPCResponse<Result>.self, from: responseJSON.data(using: .utf8)!)
        let web3Response: Web3Response<Result> = Web3Response(rpcResponse: response )
        callback(web3Response)
    }
}
