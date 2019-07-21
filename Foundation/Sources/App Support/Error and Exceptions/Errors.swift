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

public protocol ComplexError : Error {
    var underlyingError: Error? { get }
}

//MARK: -

extension CustomNSError {
    public var debugDescription: String {
        return self.localizedDescription
    }
    
    public var errorUserInfo: [String : Any] {
        let result = type(of: self).makeUserInfo(error: self)
        
        return result
    }
    
    private static func makeUserInfo(error: Swift.Error) -> [String : Any] {
        var userInfo: [String : Any] = [:]
        
        if let localizedError = error as? LocalizedError {
            if let description = localizedError.errorDescription {
                userInfo[NSLocalizedDescriptionKey] = description
            }
            
            if let reason = localizedError.failureReason {
                userInfo[NSLocalizedFailureReasonErrorKey] = reason
            }
            
            if let suggestion = localizedError.recoverySuggestion {
                userInfo[NSLocalizedRecoverySuggestionErrorKey] = suggestion
            }
            
            if let helpAnchor = localizedError.helpAnchor {
                userInfo[NSHelpAnchorErrorKey] = helpAnchor
            }
        }
        
        if let recoverableError = error as? RecoverableError {
            userInfo[NSLocalizedRecoveryOptionsErrorKey] = recoverableError.recoveryOptions
            userInfo[NSRecoveryAttempterErrorKey] = NSError.RecoveryAttempter()
        }
        
        if let complexError = error as? ComplexError, let underlyingError = complexError.underlyingError {
            userInfo[NSUnderlyingErrorKey] = underlyingError
        }
        
        return userInfo
    }
    
    private func provideUserInfoValue<T>(for key: String) -> T? {
        return type(of: self).provideUserInfoValue(for: self, key: key)
    }
    
    public static func provideUserInfoValue<T>(for error: Swift.Error, key: String) -> T? {
        
        let domain: String
        if let nserror = error as? CustomNSError {
            domain = type(of: nserror).errorDomain
        } else {
            domain = (error as NSError).domain
        }
        
        guard domain == self.errorDomain else {
            return nil
        }
        
        var result: Any?
        
        switch key {
        case NSDebugDescriptionErrorKey:
            result = (error as? CustomNSError)?.debugDescription ?? error.localizedDescription
            
        default:
            result = NSError.provideUserInfoValue(for: error, key: key)
            break
        }
        
        return result as? T
    }
    
    fileprivate static func provideAnyUserInfoValue(for error: Swift.Error, key: String) -> Any? {
        return provideUserInfoValue(for:error, key:key)
    }
}
