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

@available(iOS 9.0, *)
public typealias ResourceTag = NSBundleResourceRequest.Tag

@available(iOS 9.0, *)
public typealias ResourcePreservationPriority = NSBundleResourceRequest.PreservationPriority

@available(iOS 9.0, *)
public typealias ResourceLoadingPriority = NSBundleResourceRequest.LoadingPriority

extension NSBundleResourceRequest {
    public struct Tag: RawRepresentable, Hashable {
        private init() { rawValue = "" }
        
        //MARK: - RawRepresentable
        
        public typealias RawValue = String
        
        public init(rawValue: RawValue) {
            self.rawValue = rawValue
        }
        
        public let rawValue: RawValue
        
        //MARK: - Hashable
        
        public var hashValue: Int {
            return rawValue.hashValue
        }
        
        public static func ==(lhs: Tag, rhs: Tag) -> Bool {
            return lhs.rawValue == rhs.rawValue
        }
    }
    
    public struct PreservationPriority: RawRepresentable, Hashable, Comparable {
        public typealias RawValue = Double
        
        public init(rawValue: RawValue) {
            let clamped = Swift.max(Swift.min(rawValue, PreservationPriority.maxRawValue), PreservationPriority.minRawValue)
            self.rawValue = clamped
        }
        
        private init(_ value: RawValue) {
            rawValue = value
        }
        
        public let rawValue: RawValue
        
        //MARK: -
        
        public static func < (lhs: PreservationPriority, rhs: PreservationPriority) -> Bool {
            return lhs.rawValue < rhs.rawValue
        }
        
        //MARK: -
        
        public static var min: PreservationPriority {
            return PreservationPriority(minRawValue)
        }
        
        public static var max: PreservationPriority {
            return PreservationPriority(maxRawValue)
        }
        
        //MARK: -
        
        private static var minRawValue: RawValue {
            return 0.0
        }
        
        private static var maxRawValue: RawValue {
            return 1.0
        }
    }
    
    public struct LoadingPriority: RawRepresentable, Hashable, Comparable {
        public typealias RawValue = Double
        
        public init(rawValue: RawValue) {
            let clamped = Swift.max(Swift.min(rawValue, LoadingPriority.maxRawValue), LoadingPriority.minRawValue)
            self.rawValue = clamped
        }
        
        private init(_ value: RawValue) {
            rawValue = value
        }
        
        public let rawValue: RawValue
        
        //MARK: -
        
        public static func < (lhs: LoadingPriority, rhs: LoadingPriority) -> Bool {
            return lhs.rawValue < rhs.rawValue
        }
        
        //MARK: -
        
        public static var min: LoadingPriority {
            return LoadingPriority(minRawValue)
        }
        
        public static var max: LoadingPriority {
            return LoadingPriority(maxRawValue)
        }
        
        public static var urgent: LoadingPriority {
            return LoadingPriority(urgentRawValue)
        }
        
        //MARK: -
        
        private static var minRawValue: RawValue {
            return 0.0
        }
        
        private static var maxRawValue: RawValue {
            return 1.0
        }
        
        private static var urgentRawValue: RawValue {
            return NSBundleResourceRequestLoadingPriorityUrgent
        }
    }
}

extension NSBundleResourceRequest.Tag {
    public static var primary: NSBundleResourceRequest.Tag {
        let value = "Primary"
        return NSBundleResourceRequest.Tag(rawValue: value)
    }
}

extension NSBundleResourceRequest {
    public convenience init(tags: Set<Tag>, bundle: Bundle = Bundle.main) {
        let map = tags.map { $0.rawValue }
        
        self.init(tags: Set(map))
    }
    
    open var loadingPriorityValue: LoadingPriority {
        get { return LoadingPriority(rawValue: loadingPriority) }
        set { loadingPriority = newValue.rawValue }
    }
}

extension Bundle {
    
    @available(iOS 9.0, *)
    open func preservationPriority(forTag tag: ResourceTag) -> Double {
        return preservationPriority(forTag: tag.rawValue)
    }
    
    @available(iOS 9.0, *)
    open func preservationPriority(forTag tag: ResourceTag) -> ResourcePreservationPriority {
        let value: Double = preservationPriority(forTag: tag)
        
        return ResourcePreservationPriority(rawValue: value)
    }
    
    @available(iOS 9.0, *)
    open func setPreservationPriority(_ priority: Double, forTags tags: Set<ResourceTag>) {
        let map = tags.map { $0.rawValue }
        
        return setPreservationPriority(priority, forTags: Set(map))
    }
    
    @available(iOS 9.0, *)
    open func setPreservationPriority(_ priority: ResourcePreservationPriority, forTags tags: Set<ResourceTag>) {
        return setPreservationPriority(priority.rawValue, forTags: tags)
    }
}
