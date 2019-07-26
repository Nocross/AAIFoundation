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

extension String {
    public struct Localized {
        private init() {}
    }
}

extension String.Localized {
    public struct Common {
        private init() {}

        public struct Dismissal {
            private init() {}
        }

        public struct Confirmation {
            private init() {}
        }
    }
    
    public struct Error {
        private init() {}
        
        public struct Recovery {
            private init() {}
            
            public struct Option {
                private init() {}
            }
        }
        
        public struct Unknown {
            private init() {}
        }
    }
}

extension String.Localized.Error.Unknown {
    public static var description: String {
        let key = "error.recovery.unknown.desctiption"
        var result = NSLocalizedString(key, comment: "'Unknown' error description")
        
        if result == key {
            let value = "Unknown error"
            result = NSLocalizedString(key, bundle: Bundle.embeddedFramework, value: value, comment: "'Unknown' error description")
        }
        
        return result
    }
    
    public static var failureReason: String {
        let key = "error.recovery.unknown.failure-reason"
        var result = NSLocalizedString(key, comment: "'Unknown' error failure reason")
        
        if result == key {
            let value = "Failure reason - Unknown"
            result = NSLocalizedString("error.recovery.unknown.failure-reason", bundle: Bundle.embeddedFramework, value: value, comment: "'Unknown' error failure reason")
        }
        
        return result
    }
    
    public static var recoverySuggestion: String {
        let key = "error.recovery.unknown.recovery-suggestion"
        var result = NSLocalizedString(key, comment: "'Unknown' error description")
        
        if result == key {
            let value = "Try again or come back later"
            result = NSLocalizedString(key, bundle: Bundle.embeddedFramework, value: value, comment: "'Unknown' error description")
        }
        
        return result
    }
    
    public static var helpAnchor: String {
        let key = "error.recovery.unknown.help-anchor"
        var result = NSLocalizedString(key, comment: "'Unknown' error description")
        
        if result == key {
            let value = "No 'Help' documentation available"
            result = NSLocalizedString(key, bundle: Bundle.embeddedFramework, value: value, comment: "'Unknown' error description")
        }
        
        return result
    }
}

extension String.Localized.Error.Recovery.Option {
    public static var retry: String {
        let key = "error.recovery.option.retry"
        var result = NSLocalizedString(key, comment: "'Retry' error recovery option")
        
        if result == key {
            result = NSLocalizedString(key, value: "Retry", comment: "'Retry' error recovery option")
        }
        
        return result
    }
    
    public static var report: String {
        let key = "error.recovery.option.report"
        var result = NSLocalizedString(key, comment: "'Report' error recovery option")
        
        if result == key {
            result = NSLocalizedString(key, value: "Report", comment: "'Report' error recovery option")
        }
        
        return result
    }
}

//MARK: -

fileprivate extension Bundle {
    static var embeddedFramework: Bundle {
        return Bundle(for: Foundation.self)
    }
}
