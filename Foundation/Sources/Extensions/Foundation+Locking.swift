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

extension NSLock : Locking {
    public func withCritical<Result>(_ section: () throws -> Result) rethrows -> Result {
        if !`try`() {
            lock()
        }

        defer {
            unlock()
        }

        return try section()
    }
}

extension NSRecursiveLock : Locking {
    public func withCritical<Result>(_ section: () throws -> Result) rethrows -> Result {
        if !`try`() {
            lock()
        }

        defer {
            unlock()
        }

        return try section()
    }
}

extension NSCondition : Locking {
    public func withCritical<Result>(_ section: () throws -> Result) rethrows -> Result {
        lock()

        defer {
            unlock()

            broadcast()
        }

        return try section()
    }
}
