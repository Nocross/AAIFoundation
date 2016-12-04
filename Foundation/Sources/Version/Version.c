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

#include "Foundation-Bridging-Header.h"

#define INTERNAL_CONCAT(a,b) a ## b
#define VERSION_NUMBER(PREFIX) INTERNAL_CONCAT(PREFIX,FoundationVersionNumber)
#define VERSION_STRING(PREFIX) INTERNAL_CONCAT(PREFIX, FoundationVersionString)

////! Project version number for Foundation.
extern double VERSION_NUMBER(PRODUCT_NAME_PREFIX);

////! Project version string for Foundation.
extern const unsigned char VERSION_STRING(PRODUCT_NAME_PREFIX)[];


extern double getFoundationVersionNumber() __attribute__ ((used)) ;
extern const unsigned char* getFoundationVersionString() __attribute__ ((used)) ;

double getFoundationVersionNumber() {
    return VERSION_NUMBER(PRODUCT_NAME_PREFIX);
}

const unsigned char *getFoundationVersionString() {
    return VERSION_STRING(PRODUCT_NAME_PREFIX);
}
