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
    public struct Response { private init() {} }
    
    public struct Request { private init() {} }
}

//MARK: - HTTP Request

extension HTTP.Request {
    public struct Method: RawRepresentable, ExpressibleByStringLiteral {
        public typealias StringLiteralType = String
        
        public typealias RawValue = String
        
        public init(rawValue: RawValue) {
            self.init(stringLiteral: rawValue)
        }
        
        public init(stringLiteral value: StringLiteralType) {
            rawValue = value
        }
        
        public let rawValue: RawValue
    }
}

//MARK: - HTTP Methods

extension HTTP.Request.Method {
    //https://en.wikipedia.org/wiki/Hypertext_Transfer_Protocol#Summary_table
    
    //Required per https://tools.ietf.org/html/rfc1945
    public static var get: HTTP.Request.Method { return "GET" }
    public static var head: HTTP.Request.Method { return "HEAD" }
    
    //Optional
    public static var post: HTTP.Request.Method { return "POST" }
    public static var put: HTTP.Request.Method { return "PUT" }
    
    public static var delete: HTTP.Request.Method { return "DELETE" }
    
    public static var trace: HTTP.Request.Method { return "TRACE" }
    public static var options: HTTP.Request.Method { return "OPTIONS" }
    public static var connect: HTTP.Request.Method { return "CONNECT" }
    
    public static var patch: HTTP.Request.Method { return "PATCH" }
}

//MARK: - HTTP Response

extension HTTP.Response {
    public struct Status: RawRepresentable, ExpressibleByIntegerLiteral {
        public typealias IntegerLiteralType = Int
        
        public typealias RawValue = Int
        public let rawValue: RawValue
        
        public init(rawValue: RawValue) {
            self.init(integerLiteral: rawValue)
        }
        
        public init(integerLiteral value: IntegerLiteralType) {
            rawValue = value
        }
    }
}

extension HTTP.Response.Status {
    
    public struct InformationalResponse {
        public static var `continue`: HTTP.Response.Status { return 100 }
        
        public static var switchingProtocols: HTTP.Response.Status { return 101 }
        
        //WebDAV;https://tools.ietf.org/html/rfc2518
        public static var processing: HTTP.Response.Status { return 102 }
        
        //https://tools.ietf.org/html/rfc8297
        public static var earlyHints: HTTP.Response.Status { return 103 }
    }
    
    public struct Success {
        public static var ok: HTTP.Response.Status { return 200 }
        public static var noContent: HTTP.Response.Status { return 204 }
    }
    
    public struct Redirection {
        
        public static var multipleChoices: HTTP.Response.Status { return 300 }
        
        public static var movedPermanently: HTTP.Response.Status { return 301 }
        
        public static var found: HTTP.Response.Status { return 302 }
        
        public static var seeOther: HTTP.Response.Status { return 303 }
        
        //https://tools.ietf.org/html/rfc7232
        public static var notModified: HTTP.Response.Status { return 304 }
        
        public static var useProxy: HTTP.Response.Status { return 305 }
        
        public static var switchProxy: HTTP.Response.Status { return 306 }
        
        public static var temporaryRedirect: HTTP.Response.Status { return 307 }
        
        //https://tools.ietf.org/html/rfc7538
        public static var permanentRedirect: HTTP.Response.Status { return 308 }
    }
    
    public struct ClientErrors {
        public static var badRequest: HTTP.Response.Status { return 400 }
        
        public static var unauthorized: HTTP.Response.Status { return 401 }
        
        public static var paymentRequired: HTTP.Response.Status { return 402 }
        
        public static var forbidden: HTTP.Response.Status { return 403 }
        
        public static var notFound: HTTP.Response.Status { return 404 }
        
        public static var methodNotAllowed: HTTP.Response.Status { return 405 }
        
        //https://tools.ietf.org/html/rfc7235
        public static var proxyAuthenticationRequred: HTTP.Response.Status { return 407 }
        
        public static var requestTimeout: HTTP.Response.Status { return 408 }
        
        
        //https://tools.ietf.org/html/rfc6585
        
        public static var preconditionRequired: HTTP.Response.Status { return 428 }
        
        public static var tooManyRequests: HTTP.Response.Status { return 429 }
        
        public static var requestHeaderFieldsTooLarge: HTTP.Response.Status { return 431 }
        
        
        //https://tools.ietf.org/html/rfc7725
        public static var unavailableForLegalReasons: HTTP.Response.Status { return 451 }
    }
    
    public struct ServerErrors {
        public static var internalError: HTTP.Response.Status { return 500 }
        
        public static var notImplemented: HTTP.Response.Status { return 501 }
        
        public static var badGateway: HTTP.Response.Status { return 502 }
        
        public static var serviceUnavailable: HTTP.Response.Status { return 503 }
        
        public static var gatewayTimeout: HTTP.Response.Status { return 504 }
        
        //https://tools.ietf.org/html/rfc6585
        public static var networkAuthenticationRequired: HTTP.Response.Status { return 511 }
    }
}
