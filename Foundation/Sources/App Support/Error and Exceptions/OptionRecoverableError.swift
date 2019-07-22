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

public protocol OptionRecoverableError: RecoverableError {
    var options: [RecoveryOptionProtocol] { get }
}

extension OptionRecoverableError {
    public func attemptRecovery(optionIndex recoveryOptionIndex: Int, resultHandler handler: (Bool) -> Void) {
        
        let success = recoveryOptionIndex < options.count ? options[recoveryOptionIndex].attemptRecovery() : false
        
        handler(success)
    }
    
    public func attemptRecovery(optionIndex recoveryOptionIndex: Int) -> Bool {
        let success = recoveryOptionIndex < options.count ? options[recoveryOptionIndex].attemptRecovery() : false
        
        return success
    }
    
    public var recoveryOptions: [String] {
        return options.isEmpty ? options.map { $0.localizedOption } : []
    }
}

//MARK: -

public protocol RecoveryOptionProtocol {
    var localizedOption: String { get }
    
    func attemptRecovery() -> Bool
}
