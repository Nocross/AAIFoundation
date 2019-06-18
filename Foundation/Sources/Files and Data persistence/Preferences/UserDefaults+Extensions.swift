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

import Foundation

extension UserDefaults {
    public struct Key: StringRepresentableIdentifierProtocol {
        public typealias RawValue = String
        
        private init() { rawValue = "" }
        
        public init(rawValue: RawValue) {
            self.rawValue = rawValue
        }
        
        public let rawValue: RawValue
    }
}

extension UserDefaults {
    open func object<T>(for key: Key) -> T? where T: Decodable {
        guard let object = object(forKey: key.rawValue) as? T else {
            preconditionFailure("Type mismatch")
        }
        
        return object
    }
    
    open func removeObject(for key: Key) {
        removeObject(forKey: key.rawValue)
    }
    
    open func string(for key: Key) -> String? {
        return string(forKey: key.rawValue)
    }
    
    open func set(_ value: String, for key: Key) {
        return set(value, forKey: key.rawValue)
    }
    
    open func bool(for key: Key) -> Bool {
        return bool(forKey: key.rawValue)
    }
    
    open func set(_ value: Bool, for key: Key) {
        return set(value, forKey: key.rawValue)
    }
}

