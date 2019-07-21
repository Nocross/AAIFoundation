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

extension NSError {
    internal final class RecoveryAttempter {
        
        @objc(attemptRecoveryFromError:optionIndex:)
        func attemptRecovery(fromError nsError: NSError,
                             optionIndex recoveryOptionIndex: Int) -> Bool {
            let error = nsError as Swift.Error as! RecoverableError
            return error.attemptRecovery(optionIndex: recoveryOptionIndex)
        }
        
        @objc(attemptRecoveryFromError:optionIndex:delegate:didRecoverSelector:contextInfo:)
        func attemptRecovery(fromError nsError: NSError,
                             optionIndex recoveryOptionIndex: Int,
                             delegate: AnyObject?,
                             didRecoverSelector: Selector,
                             contextInfo: UnsafeMutableRawPointer?) {
            let error = nsError as Swift.Error as! RecoverableError
            error.attemptRecovery(optionIndex: recoveryOptionIndex) { success in
                __errorPerformRecoverySelector(delegate, didRecoverSelector, success, contextInfo)
            }
        }
    }
}

//MARK: -

extension NSError {
    internal static func provideUserInfoValue<T>(for error: Swift.Error, key: String) -> T? {
        var result: Any?
        
        switch key {
        case NSLocalizedDescriptionKey:
            result = (error as? LocalizedError)?.errorDescription ?? "" //supperssing implicit description generation
            
        case NSLocalizedFailureReasonErrorKey:
            result = (error as? LocalizedError)?.failureReason
            
        case NSLocalizedRecoverySuggestionErrorKey:
            result = (error as? LocalizedError)?.recoverySuggestion
            
        case NSHelpAnchorErrorKey:
            result = (error as? LocalizedError)?.helpAnchor
            
        case NSLocalizedRecoveryOptionsErrorKey:
            result = (error as? RecoverableError)?.recoveryOptions
            
        case NSRecoveryAttempterErrorKey:
            if error is RecoverableError {
                result = RecoveryAttempter()
            }
            
        default:
            break
        }
        
        return result as? T
    }
}

//MARK: -

extension NSError {
    @nonobjc
    private func provideUserInfoValue<T>(for key: String) -> T? {
        var result = userInfo[key]
        if #available(macOS 10.11, iOS 9.0, tvOS 9.0, watchOS 2.0, *) {
            if result == nil, let provider = NSError.userInfoValueProvider(forDomain: self.domain) {
                result = provider(self, key)
            }
        }
        
        return result as? T
    }
}

