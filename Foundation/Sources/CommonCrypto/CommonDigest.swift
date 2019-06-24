/*
    Copyright (c) 2019 Andrey Ilskiy.

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
 */

import CommonCrypto

public struct SHA1Hasher: DigestHasherProtocol {
    private var context = CC_SHA1_CTX()
    
    public init() {
        let err = CC_SHA1_Init(&context)
        
        guard err == 1 else {
            preconditionFailure("Failed to create digest context")
        }
    }
    
    @inlinable
    public mutating func combine<H>(_ value: H) where H : DigestHashable {
        value.hash(into: &self)
    }
    
    public mutating func combine(bytes: UnsafeRawBufferPointer) {
        
       let err = CC_SHA1_Update(&context, bytes.baseAddress, numericCast(bytes.count))
        guard err == 1 else { preconditionFailure("Failed to update digest")}
    }
    
    public func finalize() -> UnsafeBufferPointer<UInt8> {
        let result = UnsafeMutableBufferPointer<UInt8>.allocate(capacity: SHA1Hasher.digestLength)
        
        let err = withUnsafePointer(to: context) { CC_SHA1_Final(result.baseAddress, UnsafeMutablePointer(mutating: $0))
        }
        
        guard err == 1 else { preconditionFailure("Failed to finalize digest")}
        
        return UnsafeBufferPointer(result)
    }
    
    public static var digestLength: Int {
        return numericCast(CC_SHA1_DIGEST_LENGTH)
    }
    
    public static var blockBytes: Int {
        return numericCast(CC_SHA1_BLOCK_BYTES)
    }
    
    public static var blockLong: Int {
        let size = MemoryLayout<CC_LONG>.size
        let result = blockBytes / size
        
        return result
    }
}


public struct SHA224Hasher: DigestHasherProtocol {
    let context: UnsafeMutablePointer<CC_SHA256_CTX>
    
    public init() {
        context = .allocate(capacity: 1)
        
        let err = CC_SHA224_Init(context)
        
        guard err == 1 else {
            preconditionFailure("Failed to create digest context")
        }
    }
    
    @inlinable
    public mutating func combine<H>(_ value: H) where H : DigestHashable {
        value.hash(into: &self)
    }
    
    public mutating func combine(bytes: UnsafeRawBufferPointer) {
        
        let err = CC_SHA224_Update(context, bytes.baseAddress, numericCast(bytes.count))
        guard err == 1 else { preconditionFailure("Failed to update digest")}
    }
    
    public func finalize() -> UnsafeBufferPointer<UInt8> {
        let result = UnsafeMutableBufferPointer<UInt8>.allocate(capacity: SHA1Hasher.digestLength)
        
        let err = CC_SHA224_Final(result.baseAddress, context)
        
        guard err == 1 else { preconditionFailure("Failed to finalize digest")}
        
        return UnsafeBufferPointer(result)
    }
    
    public static var digestLength: Int {
        return numericCast(CC_SHA224_DIGEST_LENGTH)
    }
    
    public static var blockBytes: Int {
        return numericCast(CC_SHA224_BLOCK_BYTES)
    }
    
    public static var blockLong: Int {
        let size = MemoryLayout<CC_LONG>.size
        let result = blockBytes / size
        
        return result
    }
}
