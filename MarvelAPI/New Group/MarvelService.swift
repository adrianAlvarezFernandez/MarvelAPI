//
//  MarvelService.swift
//  MarvelAPI
//
//  Created by adrian.a.fernandez on 12/10/2018.
//  Copyright © 2018 adrian.a.fernandez. All rights reserved.
//

import TRON

class MarvelService {
    
    static let shared: MarvelService = MarvelService()
    
    private let baseURL: String = "http://gateway.marvel.com/v1/public/"
    private var publicKey: String = ""
    private var privateKey: String = ""
    private lazy var tron: TRON! = {
       return TRON(baseURL: baseURL)
    }()
    
    init() {
        if let publicKey = Bundle.main.object(forInfoDictionaryKey: "MarvelPublicKey") as? String, let privateKey = Bundle.main.object(forInfoDictionaryKey: "MarvelPrivateKey") as? String {
            self.publicKey = publicKey
            self.privateKey = privateKey
        }
    }
    
    internal func fetchData(withSuccess: ((MarvelModel) -> Void)?, failure: ((APIError<MarvelError>) -> Void)?) {
        
        let request: APIRequest<MarvelModel, MarvelError> = tron.codable.request("characters")
        let ts = "\(Int(NSDate().timeIntervalSince1970))"
        var value = (ts + privateKey + publicKey)
        let params = [
            "ts": ts,
            "apikey": publicKey,
            "hash": value.md5()
        ]
        
        request.parameters = params
        request.perform(withSuccess: withSuccess, failure: failure)
    }
}
