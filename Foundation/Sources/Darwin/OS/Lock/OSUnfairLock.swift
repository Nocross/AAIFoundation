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

import Darwin.os.lock

@available(OSX 10.12, *) @available(iOS 10.0, *) @available(tvOS 10, *) @available(watchOS 3.0, *)
public final class OSUnfairLock {
    fileprivate var _lock = os_unfair_lock_make()

    //MARK: -

    public init() {}

    deinit {
        os_unfair_lock_free(_lock)
    }

    //MARK: -

    func `try`() -> Bool {
        return os_unfair_lock_trylock(_lock)
    }

    public func lock() {
        os_unfair_lock_lock(_lock)
    }

    public func unlock() {
        os_unfair_lock_unlock(_lock)
    }

    public func withCritical<Result>(_ section: () throws -> Result) rethrows -> Result {
        if !os_unfair_lock_trylock(_lock) {
            os_unfair_lock_lock(_lock)
        }

        defer {
            os_unfair_lock_unlock(_lock)
        }

        return try section()
    }
}

//MARK: -

private func os_unfair_lock_make(_ count: Int = 1) -> os_unfair_lock_t {
    #if DEBUG
        if OS_LOCK_API_VERSION != 20160309 {
            fatalError("OS_LOCK_API_VERSION Changed - Revise OS_UNFAIR_LOCK_INIT implementation")
        }
    #endif

    let lock = os_unfair_lock_t.allocate(capacity: Int(count))
    lock.initialize(to: os_unfair_lock_s(_os_unfair_lock_opaque: 0), count: count)
    return lock
}

private func os_unfair_lock_free(_ lock: os_unfair_lock_t, count: Int = 1) {
    for i in 0...count {
        precondition(os_unfair_lock_trylock(lock + i), "Unlock the lock before destroying it")
        os_unfair_lock_unlock(lock + i)
    }

    lock.deinitialize()
    lock.deallocate(capacity: count)
}
