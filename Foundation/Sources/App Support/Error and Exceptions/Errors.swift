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

fileprivate struct UnknownError: Error, RecoverableError, LocalizedError, CustomNSError {
    private let handler: (() -> Bool)?
    
    init(retry handler: (() -> Bool)? = nil) {
        self.handler = handler
        
        if handler == nil {
            recoveryOptions = []
        } else {
            let retry = String.Localized.Error.Recovery.Option.retry
            recoveryOptions = [retry]
        }
    }
    
    //MARK: - RecoverableError
    
    let recoveryOptions: [String]
    
    func attemptRecovery(optionIndex recoveryOptionIndex: Int) -> Bool {
        let isRelevant = !recoveryOptions.isEmpty && recoveryOptionIndex == recoveryOptions.startIndex
        
        return isRelevant ? (handler?() ?? false) : false
    }
    
    func attemptRecovery(optionIndex recoveryOptionIndex: Int, resultHandler handler: @escaping (Bool) -> Void) {
        let qos = DispatchQoS.ofSelf
        let queue = DispatchQueue.global(qos: qos)
        
        queue.async {
            let hasRecovered = self.attemptRecovery(optionIndex: recoveryOptionIndex)
            handler(hasRecovered)
        }
    }
    
    //MARK: - LocalizedError
    
    var errorDescription: String? {
        return String.Localized.Error.Unknown.description
    }
    
    var failureReason: String? {
        return String.Localized.Error.Unknown.failureReason
    }
    
    var recoverySuggestion: String? {
        return String.Localized.Error.Unknown.recoverySuggestion
    }
    
    var helpAnchor: String? {
        return String.Localized.Error.Unknown.helpAnchor
    }
}

public func makeUnknownError(retry handler: (() -> Bool)? = nil ) -> Error {
    return UnknownError(retry: handler)
}
