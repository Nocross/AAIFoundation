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

import Dispatch
import Foundation

extension OperationQueue {
    public convenience init(qualityOfService: QualityOfService, shouldUseUnderlyingQueue: Bool = false) {
        self.init()
        
        self.qualityOfService = qualityOfService
        
        if shouldUseUnderlyingQueue {
            let queue = DispatchQueue.global(qos: qualityOfService.dispatchQoS)
            self.underlyingQueue = queue
        }
    }
    
    public static var ofSelf: OperationQueue {
        let value = QualityOfService.current
        return OperationQueue(qualityOfService: value)
    }
    
    public static var inferred: OperationQueue {
        return current ?? ofSelf
    }
}

extension DispatchQueue {
    public class func global(qos: DispatchQoS = .default) -> DispatchQueue {
        return self.global(qos: qos.qosClass)
    }
}
