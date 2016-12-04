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

extension Operation {
    public class AsynchronousExecution {
        fileprivate let lock: Locking = OSUnfairLock()
        fileprivate var executing = false
        fileprivate var finished = false
        fileprivate var cancelled = false

        weak fileprivate var operation: Operation?
        
        //MARK: -

        public init() {}
    }
}

//MARK: - Execution

extension Operation.AsynchronousExecution: Execution {
    public private(set) var isCancelled: Bool {
        get { return lock.withCritical { cancelled } }
        set {
            let key = #keyPath(Operation.isCancelled)
            operation?.withValueChange(for: key) { lock.withCritical { cancelled = newValue } }
        }
    }

    public private(set) var isExecuting: Bool {
        get { return lock.withCritical { executing } }
        set {
            let key = #keyPath(Operation.isExecuting)
            operation?.withValueChange(for: key) { lock.withCritical { executing = newValue } }
        }
    }
    public private(set) var isFinished: Bool {
        get { return lock.withCritical { finished } }
        set {
            let key = #keyPath(Operation.isExecuting)
            operation?.withValueChange(for: key) { lock.withCritical { finished = newValue } }
        }
    }

    @available(iOS 7.0, *)
    public var isAsynchronous: Bool {
        return true
    }

    public func prepare(for op: Operation) {
        lock.lock()

        operation = op

        lock.unlock()
    }

    public func start() {
        let isValid = lock.withCritical { !(executing && finished && cancelled) }
        if isValid {
            isExecuting = true
        }
    }

    public func cancel(withCompletion handler: (() throws -> Void)? = nil) rethrows -> Void {
        if isFinished {
            try handler?()
        } else {
            finalize(withCompletion: handler)
        }
    }

    public func finalize(withCompletion finalizer: (() throws -> Void)? = nil) rethrows -> Void {
        defer {
            isExecuting = false
            if !isCancelled {
                isFinished = true
            }
        }

        try finalizer?()
    }
}