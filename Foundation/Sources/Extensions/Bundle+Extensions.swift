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

extension Bundle {
    public struct Version: RawRepresentable, Hashable {
        public typealias RawValue = String

        public let major: Int
        public let minor: Int
        public let patch: Int
        public let build: Int?

        public init?(rawValue: RawValue) {
            let components = rawValue.components(separatedBy: ".").compactMap { return Int($0) }
            guard components.count >= 2 else {
                return nil
            }

            major = components[0]
            minor = components[1]
            patch = components.count >= 3 ? components[2] : 0

            build = components.count == 4 ? components[3] : nil
        }

        public var rawValue: String {
            var result = "\(major).\(minor).\(patch)"

            if let unwrapped = build {
                result.append(".\(unwrapped)")
            }

            return result
        }

        public var hashValue: Int {
            return rawValue.hash
        }

        public static func ==(lhs: Version, rhs: Version) -> Bool {
            var result = lhs.major == rhs.major
            result = result && lhs.minor == rhs.minor
            result = result && lhs.patch == rhs.patch
            result = result && lhs.build == rhs.build

            return result
        }
    }

    public var version: Version {
        var key = kCFBundleVersionKey as String
        guard let versionString = self.infoDictionary?[key] as? String else { preconditionFailure("Failed to aquire version string from Info dictionary for key - \(key)") }
        key = "CFBundleShortVersionString"
        guard let shortVersionString = self.infoDictionary?[key] as? String else { preconditionFailure("Failed to aquire version string from Info dictionary for key - \(key)") }
        guard let result = Version(rawValue: "\(shortVersionString).\(versionString)") else { preconditionFailure("Failed to create \(Bundle.Version.self) from \(versionString)") }
        return result
    }
}

extension Bundle {
    public var localizedDisplayName: String {
        let key = "CFBundleDisplayName"
        guard let result = self.localizedInfoDictionary?[key] as? String else { preconditionFailure("Failed to get \(key) from \(self)") }
        return result
    }
    
    public var name: String {
        let key = kCFBundleNameKey as String
        guard let result = self.infoDictionary?[key] as? String else { preconditionFailure("Failed to get \(key) from \(self)") }
        
        return result
    }
}
