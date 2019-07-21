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
import InteroperabilityShims

public protocol PromotedNSExceptionErrorProtocol: Error {
    var name: NSExceptionName { get }
    
    var reason: String? { get }
    
    var userInfo: [AnyHashable : Any]? { get }
    
    @available(iOS 2.0, *)
    var callStackReturnAddresses: [UInt64] { get }
    
    @available(iOS 4.0, *)
    var callStackSymbols: [String] { get }
    
    var underlyingException: NSException { get }
    
    init(underlying exception: NSException)
    
    init(name aName: NSExceptionName, reason aReason: String?, userInfo aUserInfo: [AnyHashable : Any]?)
}

fileprivate struct NSExceptionError: Error, PromotedNSExceptionErrorProtocol {
    public var name: NSExceptionName {
        return underlyingException.name
    }
    
    public var reason: String? {
        return underlyingException.reason
    }
    
    public var userInfo: [AnyHashable : Any]? {
        return underlyingException.userInfo
    }
    
    
    @available(tvOS 9.0, *)
    public var callStackReturnAddresses: [UInt64] {
        return underlyingException.callStackReturnAddresses.map { return $0.uint64Value }
    }
    
    @available(tvOS 9.0, *)
    public var callStackSymbols: [String] {
        return underlyingException.callStackSymbols
    }
    
    public let underlyingException: NSException
    
    public init(underlying exception: NSException) {
        underlyingException = exception
    }
    
    public init(name aName: NSExceptionName, reason aReason: String?, userInfo aUserInfo: [AnyHashable : Any]? = nil) {
        underlyingException = NSException(name: aName, reason: aReason, userInfo: aUserInfo)
    }
}

//MARK: -

public func withPromotedException<Result>(_ body: () throws -> Result ) throws -> Result {
    var result: Outcome<Result, Error> = nil
    
    var exception: NSException?
    let exceptionPointer = AutoreleasingUnsafeMutablePointer<NSException?>(&exception)
    
    __catchNSException(exceptionPointer) {
        do { result = .conclusion(try body()) }
        catch { result = .error(error) }
    }
    
    guard exceptionPointer.pointee == nil else {
        throw NSExceptionError(underlying: exceptionPointer.pointee!)
    }

    return try result.get()
}
