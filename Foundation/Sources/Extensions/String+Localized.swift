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
    }
}

extension String.Localized.Error.Recovery.Option {
    public static var retry: String {
        return NSLocalizedString("error.recovery.option.retry", value: "Retry", comment: "'Retry' error recovery option")
    }
    
    public static var report: String {
        return NSLocalizedString("error.recovery.option.report", value: "Report", comment: "'Report' error recovery option")
    }
}
