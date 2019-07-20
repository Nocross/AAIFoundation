/*
    Copyright (c) 2019 Leonid Basov.

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

public struct HTTP {
    public struct Response {}
    
    public struct Request {}
}

public extension HTTP.Response {
    struct Status: RawRepresentable, ExpressibleByIntegerLiteral {
        public typealias IntegerLiteralType = Int
        
        public typealias RawValue = Int
        public var rawValue: Int
        
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
        
        public init(integerLiteral value: IntegerLiteralType) {
            self.rawValue = value
        }
    }
}

extension HTTP.Response.Status {
    
    public typealias Status = HTTP.Response.Status
    
    
    public struct Success {
        public static var ok: Status { return 200 }
        public static var noContent: Status { return 204 }
    }
    
    public struct Redirection {
        public static var movedPermanently: Status { return 301 }
    }
    
    public struct ClientErrors {
        public static var badRequest: Status { return 400 }
        public static var unauthorized: Status { return 401 }
        public static var forbidden: Status { return 403 }
        public static var notFound: Status { return 404 }
        public static var methodNotAllowed: Status { return 405 }
    }
    
    public struct ServerErrors {
        public static var internalError: Status { return 500 }
        public static var badGateway: Status { return 502 }
        public static var serviceUnavailable: Status { return 503 }
        public static var gatewayTimeout: Status { return 504 }
    }
}
