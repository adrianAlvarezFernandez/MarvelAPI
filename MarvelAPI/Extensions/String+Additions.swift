//
//  String+Additions.swift
//  MarvelAPI
//
//  Created by adrian.a.fernandez on 12/10/2018.
//  Copyright © 2018 adrian.a.fernandez. All rights reserved.
//

import CommonCrypto
extension String {
    
    //Hash md5 by string.
    mutating func md5() -> String {
        
        let context = UnsafeMutablePointer<CC_MD5_CTX>.allocate(capacity: 1)
        var digest = Array<UInt8>(repeating:0, count:Int(CC_MD5_DIGEST_LENGTH))
        CC_MD5_Init(context)
        CC_MD5_Update(context, self, CC_LONG(self.lengthOfBytes(using: String.Encoding.utf8)))
        CC_MD5_Final(&digest, context)
        context.deallocate()
        var hexString = ""
        for byte in digest {
            hexString += String(format:"%02x", byte)
        }
        
        return hexString
    }
    
}
