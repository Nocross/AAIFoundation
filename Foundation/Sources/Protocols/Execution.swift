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

public protocol Execution {
    var isCancelled: Bool { get }

    var isExecuting: Bool { get }

    var isFinished: Bool { get }

    @available(iOS 7.0, *)
    var isAsynchronous: Bool { get }

    func prepare(for op: Operation) -> Void

    func start() -> Bool

    func cancel(finalized: Bool, withCompletion handler: (() throws -> Void)?) rethrows -> Void

    func finalize(withCompletion: (() throws -> Void)?) rethrows -> Void
}

extension Execution {
    public func cancel(finalized: Bool = true) {
        cancel(finalized: finalized, withCompletion: nil)
    }

    public func finalize() {
        finalize(withCompletion: nil)
    }
}
