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

extension URL {
    public struct Scheme: StringRepresentableIdentifierProtocol {
        public typealias RawValue = String
        
        public let rawValue: RawValue
        
        public init(rawValue: RawValue) {
            self.rawValue = rawValue
        }
    }
}

//MARK: -

extension URLComponents {
    public var schemeValue: URL.Scheme? {
        return scheme == nil ? nil : URL.Scheme(rawValue: scheme!)
    }
}

//MARK: -

extension URL {
    public var schemeValue: Scheme? {
        return scheme == nil ? nil : URL.Scheme(rawValue: scheme!)
    }

    public var email: String? {
        return schemeValue == .mailto ? URLComponents(url: self, resolvingAgainstBaseURL: false)?.path : nil
    }
}

//MARK: -

extension URL.Scheme {
    
    //RFC2368 - https://tools.ietf.org/html/rfc2368
    public static var mailto: URL.Scheme {
        return URL.Scheme(rawValue: "mailto")
    }
}
