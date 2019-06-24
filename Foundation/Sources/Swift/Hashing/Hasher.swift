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

public protocol DigestHasherProtocol {
    mutating func combine<H>(_ value: H) where H : DigestHashable
    
    mutating func combine(bytes: UnsafeRawBufferPointer)
    
    __consuming func finalize() -> UnsafeBufferPointer<UInt8>
}

extension DigestHasherProtocol {
    public func finalize() -> [UInt8] {
        let buffer = finalize()
        
        var result = Array<UInt8>()
        result.withUnsafeMutableBufferPointer {
            $0 = UnsafeMutableBufferPointer(mutating: buffer)
        }
        
        return result
    }
}

//MARK: -

public protocol DigestHashable: Hashable {
    func hash<T>(into hasher: inout T) where T : DigestHasherProtocol
}

extension DigestHashable where Self : Numeric {
    public func hash<T>(into hasher: inout T) where T : DigestHasherProtocol {
        withUnsafeBytes(of: self) { hasher.combine(bytes: $0) }
    }
}

extension DigestHashable where Self : StringProtocol {
    public func hash<T>(into hasher: inout T) where T : DigestHasherProtocol {
        self.withContiguousStorageIfAvailable {
            let pointer = UnsafeRawBufferPointer($0)
            hasher.combine(bytes: pointer)
        }
    }
}

//MARK: -

extension Hasher: DigestHasherProtocol {
    public func finalize() -> UnsafeBufferPointer<UInt8> {
        
        var value = finalize() as Int
        
        let raw = UnsafeRawBufferPointer(start: &value, count: MemoryLayout<Int>.size)
        
        let result = raw.bindMemory(to: UInt8.self)
        
        return result
    }
}

extension String {
    public init<T>(hexadecimal buffer: UnsafeBufferPointer<T>) where T : UnsignedInteger, T : CVarArg {
        let result = buffer.reduce(into: "") { (result , integer) in
            let partial = String(format: "%02hhx", integer)
            result.append(contentsOf: partial)
        }
        
        self.init(result)
    }
}

//MARK: -

import Foundation

extension DigestHashable where Self : ContiguousBytes {
    public func hash<T>(into hasher: inout T) where T : DigestHasherProtocol {
        withUnsafeBytes { hasher.combine(bytes: $0) }
    }
}

extension Data: DigestHashable {}
