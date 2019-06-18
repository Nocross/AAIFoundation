/*
    Copyright (c) 2017 Andrey Ilskiy.

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


fileprivate typealias didRecoverIMP = @convention(c) (Any, Selector, Bool, UnsafeMutableRawPointer?) -> Void

@objc
public protocol ErrorRecoveryAttemptingDelegate {
    //- (void)didPresentErrorWithRecovery:(BOOL)didRecover contextInfo:(void *)contextInfo;

    @objc(didPresentErrorWithRecovery:contextInfo:)
    func didRecoverFromPresentedError(_ didRecover: Bool, contextInfo: UnsafeMutableRawPointer?)
}

//MARK: -

/*
Formal counterpart for protocol NSErrorRecoveryAttempting informal protocol
*/

@objc
public protocol ErrorRecoveryAttempting: class {
    @objc(attemptRecoveryFromError:optionIndex:delegate:contextInfo:)
    optional func attemptRecovery(fromError error: Error, optionIndex recoveryOptionIndex: Int, delegate: ErrorRecoveryAttemptingDelegate?, contextInfo: UnsafeMutableRawPointer?)

    //- (void)attemptRecoveryFromError:(NSError *)error optionIndex:(NSUInteger)recoveryOptionIndex delegate:(id)delegate didRecoverSelector:(SEL)didRecoverSelector contextInfo:(void *)contextInfo;

    @objc(attemptRecoveryFromError:optionIndex:delegate:didRecoverSelector:contextInfo:)
    optional func attemptRecovery(fromError error: Error, optionIndex recoveryOptionIndex: Int, delegate: Any?, didRecoverSelector: Selector?, contextInfo: UnsafeMutableRawPointer?)

    //- (BOOL)attemptRecoveryFromError:(NSError *)error optionIndex:(NSUInteger)recoveryOptionIndex;

    @objc(attemptRecoveryFromError:optionIndex:)
    optional func attemptRecovery(fromError error: Error, optionIndex recoveryOptionIndex: Int) -> Bool
}

extension ErrorRecoveryAttempting {

    public func attemptRecovery(fromError error: Error, optionIndex recoveryOptionIndex: Int, delegate: Any?, didRecoverSelector: Selector?, contextInfo: UnsafeMutableRawPointer?) {
        guard self.attemptRecovery(fromError:optionIndex:) != nil && delegate != nil && didRecoverSelector != nil else { return }

        let selector = #selector(ErrorRecoveryAttemptingDelegate.didRecoverFromPresentedError)
        precondition(didRecoverSelector == selector, "didRecoverSelector signature mismatch, passed selector - \(String(describing: didRecoverSelector))")

        let cls: AnyClass! = object_getClass(delegate)
        precondition(cls != nil, "delegate doesn't have an Objective-C class")
        precondition(class_respondsToSelector(cls, selector), "class - \(String(describing: cls)) doesn't respond to selector - \(selector)")

        let imp = class_getMethodImplementation(cls, selector)
        precondition(imp != nil, "Missing implementation for selector - \(selector)")

        let function = unsafeBitCast(imp, to: didRecoverIMP.self)

        let didRecover = self.attemptRecovery!(fromError: error, optionIndex: recoveryOptionIndex)
        function(delegate!, selector, didRecover, contextInfo)
    }

    public func attemptRecovery(fromError error: Error, optionIndex recoveryOptionIndex: Int, delegate: ErrorRecoveryAttemptingDelegate?, contextInfo: UnsafeMutableRawPointer?) {
        if let delegate = delegate, self.attemptRecovery(fromError:optionIndex:) != nil {
            let selector = #selector(ErrorRecoveryAttemptingDelegate.didRecoverFromPresentedError)

            self.attemptRecovery!(fromError: error, optionIndex: recoveryOptionIndex, delegate: delegate, didRecoverSelector: selector, contextInfo: contextInfo)
        }
    }
}
