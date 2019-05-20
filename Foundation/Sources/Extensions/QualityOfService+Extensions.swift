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

import Darwin.sys.qos
import Dispatch
import Foundation

extension QualityOfService {
	public var dispatchQoS: DispatchQoS {
		let result: DispatchQoS
		
		switch self {
		case .userInteractive:
			result = .userInteractive
		case .userInitiated:
			result = .userInitiated
		case .utility:
			result = .utility
		case .background:
			result = .background
		case .default:
			result = .default
        @unknown default:
            fatalError("Unknown quality of service value - \(self.rawValue)")
        }
		
		return result
	}
	
	public static var current: QualityOfService {
		return QualityOfService(dispatchQoS: DispatchQoS.ofSelf)
	}
	
	public init(dispatchQoS: DispatchQoS) {
		let result: QualityOfService?
		
		switch dispatchQoS.qosClass {
		case .background:
			result = .background
		case .utility:
			result = .utility
		case .default:
			result = .default
		case .userInitiated:
			result = .userInitiated
		case .userInteractive:
			result = .userInteractive
			
		case .unspecified:
			fallthrough
		default:
            let value: RawValue = numericCast(dispatchQoS.qosClass.rawValue.rawValue)
			result = QualityOfService(rawValue: value)
		}
		assert(result != nil, "Unmappable Dispatch QoS - \(dispatchQoS)")
		
		self = result ?? .utility
	}
}

extension DispatchQoS {
    public static var ofSelf: DispatchQoS {
        let value = numericCast(QOS_MAX_RELATIVE_PRIORITY) as Int
        return makeRelativeOfSelf(relativePriority: value)
    }
    
    public static func makeRelativeOfSelf(relativePriority: Int) -> DispatchQoS {
        let min: Int = numericCast(QOS_MIN_RELATIVE_PRIORITY)
        let max: Int = numericCast(QOS_MAX_RELATIVE_PRIORITY)
        let clamped = Swift.max(Swift.min(max, relativePriority), min)
        
        return DispatchQoS(qosClass: QoSClass.ofSelf, relativePriority: clamped)
    }
}

extension DispatchQoS.QoSClass {
    public static var ofSelf: DispatchQoS.QoSClass {
        let qos = qos_class_self()
        
        guard let result = DispatchQoS.QoSClass(rawValue: qos) else {
            assertionFailure("Unmappable qos_class_t - \(qos)")
            
            return DispatchQoS.QoSClass.utility
        }
        
        return result
    }
}

fileprivate var QOS_MAX_RELATIVE_PRIORITY: Int32 { return 0 }
