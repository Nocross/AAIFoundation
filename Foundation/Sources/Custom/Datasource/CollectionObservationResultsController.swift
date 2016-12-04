/*
    Copyright (c) 2016 Andrey Ilskiy.

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

open class CollectionObservationResultsController: NSObject {

    open let observationTarget: NSObject
    open let relationshipKeyPath: String

    open fileprivate(set) var collection: AnyObject!


    public init(withObservationTarget target: NSObject, relationshipKeyPath keyPath: String) {
        precondition(!keyPath.isEmpty, "keyPath is empty")

        observationTarget = target
        relationshipKeyPath = keyPath
    }

    deinit {
        observationTarget.removeObserver(self, forKeyPath: relationshipKeyPath)
    }

    open func beginObservation() throws {
        observationTarget.addObserver(self, forKeyPath: relationshipKeyPath, options: .new, context: nil)
    }

    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        if let dict = change, object as? NSObject === observationTarget, keyPath == relationshipKeyPath {
            self.process(dict)
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }

    fileprivate func process(_ change: [NSKeyValueChangeKey: Any]) {
        guard let kind = (change[.kindKey] as? NSNumber) else {
            return
        }

        switch kind.uintValue {
        case NSKeyValueChange.setting.rawValue:
            break
        case NSKeyValueChange.insertion.rawValue:
            break
        case NSKeyValueChange.removal.rawValue:
            break
        case NSKeyValueChange.replacement.rawValue:
            break
        default:
            preconditionFailure("Unsupported change kind - \(kind)")
        }
    }
}

public protocol CollectionObservationResultsControllerDelegate: NSObjectProtocol {
}

