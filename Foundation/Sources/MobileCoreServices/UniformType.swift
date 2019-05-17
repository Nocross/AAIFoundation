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

import CoreFoundation
import Foundation
import MobileCoreServices

@available(iOS 3.0, *)
public struct UniformType: RawRepresentable, Hashable {
    public typealias DeclarationKey = Declaration.Key

    fileprivate let uti: CFString

    fileprivate init(coreType: CFString) {
        precondition(CFStringGetLength(coreType) > 0, "coreType can not be empty")

        uti = coreType
    }

    //MARk - RawRepresentable

    public init?(rawValue: String) {
        if rawValue.isEmpty {
            return nil
        } else {
            uti = rawValue as CFString
        }
    }

    public var rawValue: String {
        return uti as String
    }

    //MARK: - Hashable

    public var hashValue: Int {
        return numericCast(CFHash(uti))
    }

    //MARK: - Equatable

    public static func ==(lhs: UniformType, rhs: UniformType) -> Bool {
        return UTTypeEqual(lhs.uti, rhs.uti)
    }
}

//MARK: - UniformType Methods

extension UniformType {
    func preferredTag(in tagClass: TagClass) -> String? {
        var result: String? = nil

        if let tag = UTTypeCopyPreferredTagWithClass(uti, tagClass.tag) {
            result = tag.takeRetainedValue() as String
        }

        return result
    }

    func allTags(in tagClass: TagClass) -> [String]? {
        var result: [String]? = nil

        if let tags = UTTypeCopyAllTagsWithClass(uti, tagClass.tag) {
            result = tags.takeRetainedValue() as? [String]
        }

        return result
    }

    public func conforms(to type: UniformType) -> Bool {
        return UTTypeConformsTo(self.uti, type.uti)
    }

    public var description: String? {
        var result: String? = nil

        if let description = UTTypeCopyDescription(uti) {
            result = description.takeRetainedValue() as String
        }

        return result
    }

    @available(iOS 8.0, *)
    public var isDeclared: Bool {
        return UTTypeIsDeclared(uti)
    }

    @available(iOS 8.0, *)
    public var isDynamic: Bool {
        return UTTypeIsDynamic(uti)
    }

    public var declaration: Declaration? {
        var result: Declaration? = nil

        if let unmanaged = UTTypeCopyDeclaration(uti) {
            let dictionary = unmanaged.takeRetainedValue()
            result = Declaration(declarationValue: dictionary)
        }

        return result
    }

    public var declaringBundleURL: URL? {
        var result: URL? = nil

        if let url = UTTypeCopyDeclaringBundleURL(uti) {
            result = url.takeRetainedValue() as URL
        }

        return result
    }
}

//MARK: - UniformType.TagClass

extension UniformType {
    public struct TagClass: RawRepresentable, Hashable {
        fileprivate let tag: CFString

        public init?(rawValue: String) {
            if rawValue.isEmpty {
                return nil
            } else {
                tag = rawValue as CFString
            }
        }

        public var rawValue: String {
            return tag as String
        }

        fileprivate init(coreTagClass: CFString) {
            precondition(CFStringGetLength(coreTagClass) > 0, "coreTagClass can not be empty")

            tag = coreTagClass
        }

        //MARK: - Hashable

        public var hashValue: Int {
            return (tag as String).hashValue
        }

        //MARK: - Equatable

        public static func ==(lhs: TagClass, rhs: TagClass) -> Bool {
            let flags = CFStringCompareFlags.compareCaseInsensitive

            return CFStringCompare(lhs.tag, rhs.tag, flags) == .compareEqualTo
        }
    }

}

//MARK: - UniformType.TagClass Methods

extension UniformType.TagClass {
    public func preferredIdentifier(for tag: String, conforming toType: UniformType) -> UniformType? {
        var result: UniformType? = nil

        if let identifier = UTTypeCreatePreferredIdentifierForTag(self.tag, tag as CFString, toType.uti) {
            result = UniformType(coreType: identifier.takeRetainedValue())
        }

        return result
    }

    public func allIdentifiers(for tag: String, conforming toType: UniformType?) -> [UniformType]? {
        var result: [UniformType]? = nil

        if let identifiers = UTTypeCreateAllIdentifiersForTag(self.tag, tag as CFString, toType?.uti) {
            let utis = identifiers.takeRetainedValue() as? [CFString]

            result = utis?.map {
                UniformType(coreType: $0)
            }
        }

        return result
    }
}

//MARK - Core UniformType.TagClass(es)

extension UniformType.TagClass {
    public static var filenameExtension: UniformType.TagClass {
        return UniformType.TagClass(coreTagClass: kUTTagClassFilenameExtension)
    }

    public static var mimeType: UniformType.TagClass {
        return UniformType.TagClass(coreTagClass: kUTTagClassMIMEType)
    }
}

//MARK: - UniformType.Declaration

extension UniformType {
    public struct Declaration: RawRepresentable {
        fileprivate let declaration: CFDictionary

        public init?(rawValue: [UniformType.Declaration.Key : Any]) {
            declaration = Declaration.map(from: rawValue)
        }

        public var rawValue: [UniformType.Declaration.Key : Any] {
            return Declaration.map(from: declaration)
        }

        fileprivate init(declarationValue: CFDictionary) {
            declaration = declarationValue
        }

        private static func map(from theDict: CFDictionary) -> [UniformType.Declaration.Key : Any] {
            var result: [UniformType.Declaration.Key : Any] = [:]

            withUnsafeMutablePointer(to: &result) {
                let pointer = UnsafeMutableRawPointer($0)
                CFDictionaryApplyFunction(theDict, applyHandler, pointer)
            }
            
            return result
        }

        private static func map(from rawValue: [UniformType.Declaration.Key : Any]) -> CFDictionary {
            var keyCallbacks = kCFTypeDictionaryKeyCallBacks
            var valueCallbacks = kCFTypeDictionaryValueCallBacks
            let keyCallbacksPtr = withUnsafePointer(to: &keyCallbacks) { return $0 }
            let valueCallbacksPtr = withUnsafePointer(to: &valueCallbacks) { return $0 }

            let theDict = CFDictionaryCreateMutable(kCFAllocatorDefault, rawValue.count, keyCallbacksPtr, valueCallbacksPtr)
            precondition(theDict != nil)
            
            let result: CFMutableDictionary = rawValue.reduce(theDict!) {
                let keyPtr = unsafeBitCast($1.key, to: UnsafeRawPointer.self)
                let valuePtr = unsafeBitCast($1.value, to: UnsafeRawPointer.self)
                CFDictionaryAddValue($0, keyPtr, valuePtr)

                return $0
            }

            return CFDictionaryCreateCopy(kCFAllocatorDefault, result)
        }
    }
}

//MARK: - UniformType.Declaration Apply Handler

fileprivate func applyHandler(keyPtr: UnsafeRawPointer?, valuePtr: UnsafeRawPointer?, contextPtr: UnsafeMutableRawPointer?) {
    let key = unsafeBitCast(keyPtr, to: CFString.self)
    let value = unsafeBitCast(valuePtr, to: CFTypeRef.self)

    var context = contextPtr!.assumingMemoryBound(to: Dictionary<UniformType.Declaration.Key, Any>.self).pointee
    context.updateValue(value, forKey: UniformType.Declaration.Key(keyValue: key))
}

//MARK: - UniformType.Declaration Properties

extension UniformType.Declaration {
    public var typeIdentifier: String? {
        let value = getDeclarationValue(for: Key.typeIdentifier, of: CFString.self)

        return value == nil ? nil : value! as String
    }

    public var typeTagSpecification: [String: Any]? {
        let value = getDeclarationValue(for: Key.typeTagSpecification, of: CFDictionary.self)

        return value == nil ? nil : value! as? [String: Any]
    }

    public var typeConformsTo: [UniformType]? {
        var result: [UniformType]?

        if let value = getDeclarationValue(for: Key.typeConformsTo, of: CFArray.self) as? [CFString] {
            result = value.map {
                UniformType(coreType: $0)
            }
        }

        return result
    }

    public var typeDescription: String? {
        let value = getDeclarationValue(for: Key.typeDescription, of: CFString.self)

        return value == nil ? nil : value! as String
    }

    public var typeIconFile: String? {
        let value = getDeclarationValue(for: Key.typeIconFile, of: CFString.self)

        return value == nil ? nil : value! as String
    }

    public var typeReferenceURL: URL? {
        let value = getDeclarationValue(for: Key.typeReferenceURL, of: CFURL.self)

        return value == nil ? nil : value! as URL
    }

    public var typeVersion: Double? {
        var result: Double?

        let value = getDeclarationValue(for: Key.typeVersion, of: CFNumber.self)
        if let actual = value {
            var doubleValue: Double = 0.0
            let success = withUnsafeMutablePointer(to: &doubleValue) { CFNumberGetValue(actual, .doubleType, $0) }
            if success {
                result = doubleValue
            }
        }

        return result
    }

    private func getDeclarationValue<U>(for key: Key, of coreType: U.Type) -> U? {
        let keyPtr = unsafeBitCast(key.key, to: UnsafeRawPointer.self)
        let valuePtr = CFDictionaryGetValue(declaration, keyPtr)

        return valuePtr == nil ? nil : unsafeBitCast(valuePtr, to: coreType)
    }
}

//MARK: - UniformType.Declaration.Key

extension UniformType.Declaration {
    public struct Key: RawRepresentable, Hashable {
        fileprivate let key: CFString

        public init?(rawValue: String) {
            key = rawValue as CFString
        }

        fileprivate init(keyValue: CFString) {
            key = keyValue
        }

        public var rawValue: String {
            return key as String
        }

        public var hashValue: Int {
            return numericCast(CFHash(key))
        }

        public static func ==(lhs: Key, rhs: Key) -> Bool {
            let flags = CFStringCompareFlags.compareCaseInsensitive

            return CFStringCompare(lhs.key, rhs.key, flags) == .compareEqualTo
        }
    }

}

//MARK: - UniformType.Declaration.Key(s)

extension UniformType.Declaration.Key {
    public static var exportedTypeDeclarations: UniformType.Declaration.Key {
        return UniformType.Declaration.Key(keyValue: kUTExportedTypeDeclarationsKey)
    }

    public static var importedTypeDeclarations: UniformType.Declaration.Key {
        return UniformType.Declaration.Key(keyValue: kUTImportedTypeDeclarationsKey)
    }

    public static var typeIdentifier: UniformType.Declaration.Key {
        return UniformType.Declaration.Key(keyValue: kUTTypeIdentifierKey)
    }

    public static var typeTagSpecification: UniformType.Declaration.Key {
        return UniformType.Declaration.Key(keyValue: kUTTypeTagSpecificationKey)
    }

    public static var typeConformsTo: UniformType.Declaration.Key {
        return UniformType.Declaration.Key(keyValue: kUTTypeConformsToKey)
    }

    public static var typeDescription: UniformType.Declaration.Key {
        return UniformType.Declaration.Key(keyValue: kUTTypeDescriptionKey)
    }

    public static var typeIconFile: UniformType.Declaration.Key {
        return UniformType.Declaration.Key(keyValue: kUTTypeIconFileKey)
    }

    public static var typeReferenceURL: UniformType.Declaration.Key {
        return UniformType.Declaration.Key(keyValue: kUTTypeReferenceURLKey)
    }

    public static var typeVersion: UniformType.Declaration.Key {
        return UniformType.Declaration.Key(keyValue: kUTTypeVersionKey)
    }
}

//MARK: - UniformType Core Types

extension UniformType {
    public static var item: UniformType {
        return UniformType(coreType: kUTTypeItem)
    }

    public static var content: UniformType {
        return UniformType(coreType: kUTTypeContent)
    }

    public static var compositeContent: UniformType {
        return UniformType(coreType: kUTTypeCompositeContent)
    }

    public static var message: UniformType {
        return UniformType(coreType: kUTTypeMessage)
    }

    public static var contact: UniformType {
        return UniformType(coreType: kUTTypeContact)
    }

    public static var archive: UniformType {
        return UniformType(coreType: kUTTypeArchive)
    }

    public static var diskImage: UniformType {
        return UniformType(coreType: kUTTypeDiskImage)
    }
}

//MARK: -

extension UniformType {
    public static var data: UniformType {
        return UniformType(coreType: kUTTypeData)
    }

    public static var directory: UniformType {
        return UniformType(coreType: kUTTypeDirectory)
    }

    public static var resolvable: UniformType {
        return UniformType(coreType: kUTTypeResolvable)
    }

    public static var symlink: UniformType {
        return UniformType(coreType: kUTTypeSymLink)
    }

    public static var executable: UniformType {
        return UniformType(coreType: kUTTypeExecutable)
    }

    public static var mountPoint: UniformType {
        return UniformType(coreType: kUTTypeMountPoint)
    }

    public static var aliasFile: UniformType {
        return UniformType(coreType: kUTTypeAliasFile)
    }

    public static var urlBookmarkData: UniformType {
        return UniformType(coreType: kUTTypeURLBookmarkData)
    }
}

//MARK: -

extension UniformType {
    public static var url: UniformType {
        return UniformType(coreType: kUTTypeURL)
    }

    public static var fileURL: UniformType {
        return UniformType(coreType: kUTTypeFileURL)
    }
}

//MARK: -

extension UniformType {
    public static var text: UniformType {
        return UniformType(coreType: kUTTypeText)
    }

    public static var plainText: UniformType {
        return UniformType(coreType: kUTTypePlainText)
    }

    public static var utf8PlainText: UniformType {
        return UniformType(coreType: kUTTypeUTF8PlainText)
    }

    public static var utf16ExternalPlainText: UniformType {
        return UniformType(coreType: kUTTypeUTF16ExternalPlainText)
    }

    public static var utf16PlainText: UniformType {
        return UniformType(coreType: kUTTypeUTF16PlainText)
    }

    @available(iOS 8.0, *)
    public static var delimitedText: UniformType {
        return UniformType(coreType: kUTTypeDelimitedText)
    }

    @available(iOS 8.0, *)
    public static var commaSeparatedText: UniformType {
        return UniformType(coreType: kUTTypeCommaSeparatedText)
    }

    @available(iOS 8.0, *)
    public static var tabSeparatedText: UniformType {
        return UniformType(coreType: kUTTypeTabSeparatedText)
    }

    @available(iOS 8.0, *)
    public static var utf8TabSeparatedText: UniformType {
        return UniformType(coreType: kUTTypeUTF8TabSeparatedText)
    }

    public static var rtf: UniformType {
        return UniformType(coreType: kUTTypeRTF)
    }
}

//MARK: -

extension UniformType {
    public static var html: UniformType {
        return UniformType(coreType: kUTTypeHTML)
    }

    public static var xml: UniformType {
        return UniformType(coreType: kUTTypeXML)
    }
}

//MARK: -

extension UniformType {
    public static var sourceCode: UniformType {
        return UniformType(coreType: kUTTypeSourceCode)
    }

    @available(iOS 8.0, *)
    public static var assemblyLanguageSource: UniformType {
        return UniformType(coreType: kUTTypeAssemblyLanguageSource)
    }

    public static var cSource: UniformType {
        return UniformType(coreType: kUTTypeCSource)
    }

    public static var objectiveCSource: UniformType {
        return UniformType(coreType: kUTTypeObjectiveCSource)
    }

    @available(iOS 9.0, *)
    public static var swiftSource: UniformType {
        return UniformType(coreType: kUTTypeSwiftSource)
    }

    public static var cPlusPlusSource: UniformType {
        return UniformType(coreType: kUTTypeCPlusPlusSource)
    }

    public static var objectiveCPlusPlusSource: UniformType {
        return UniformType(coreType: kUTTypeObjectiveCPlusPlusSource)
    }

    public static var cHeader: UniformType {
        return UniformType(coreType: kUTTypeCHeader)
    }

    public static var cPlusPlusHeader: UniformType {
        return UniformType(coreType: kUTTypeCPlusPlusHeader)
    }

    public static var javaSource: UniformType {
        return UniformType(coreType: kUTTypeJavaSource)
    }
}

//MARK: -

@available(iOS 8.0, *)
extension UniformType {
    public static var script: UniformType {
        return UniformType(coreType: kUTTypeScript)
    }

    public static var appleScript: UniformType {
        return UniformType(coreType: kUTTypeAppleScript)
    }

    public static var osaScript: UniformType {
        return UniformType(coreType: kUTTypeOSAScript)
    }

    public static var osaScriptBundle: UniformType {
        return UniformType(coreType: kUTTypeOSAScriptBundle)
    }

    public static var javaScript: UniformType {
        return UniformType(coreType: kUTTypeJavaScript)
    }

    public static var shellScript: UniformType {
        return UniformType(coreType: kUTTypeShellScript)
    }

    public static var perlScript: UniformType {
        return UniformType(coreType: kUTTypePerlScript)
    }

    public static var pythonScript: UniformType {
        return UniformType(coreType: kUTTypePythonScript)
    }

    public static var rubyScript: UniformType {
        return UniformType(coreType: kUTTypeRubyScript)
    }

    public static var phpScript: UniformType {
        return UniformType(coreType: kUTTypePHPScript)
    }
}

//MARK: -

@available(iOS 8.0, *)
extension UniformType {
    public static var json: UniformType {
        return UniformType(coreType: kUTTypeJSON)
    }

    public static var propertyList: UniformType {
        return UniformType(coreType: kUTTypePropertyList)
    }

    public static var xmlPropertyList: UniformType {
        return UniformType(coreType: kUTTypeXMLPropertyList)
    }

    public static var binaryPropertyList: UniformType {
        return UniformType(coreType: kUTTypeBinaryPropertyList)
    }
}

//MARK: -

extension UniformType {
    public static var pdf: UniformType {
        return UniformType(coreType: kUTTypePDF)
    }

    public static var rtfd: UniformType {
        return UniformType(coreType: kUTTypeRTFD)
    }

    public static var flatRTFD: UniformType {
        return UniformType(coreType: kUTTypeFlatRTFD)
    }

    public static var txnTextAndMultimediaData: UniformType {
        return UniformType(coreType: kUTTypeTXNTextAndMultimediaData)
    }

    public static var webArchive: UniformType {
        return UniformType(coreType: kUTTypeWebArchive)
    }
}

//MARK: -

extension UniformType {
    public static var image: UniformType {
        return UniformType(coreType: kUTTypeImage)
    }

    public static var jpeg: UniformType {
        return UniformType(coreType: kUTTypeJPEG)
    }

    public static var jpeg2000: UniformType {
        return UniformType(coreType: kUTTypeJPEG2000)
    }

    public static var tiff: UniformType {
        return UniformType(coreType: kUTTypeTIFF)
    }

    public static var pict: UniformType {
        return UniformType(coreType: kUTTypePICT)
    }

    public static var gif: UniformType {
        return UniformType(coreType: kUTTypeGIF)
    }

    public static var png: UniformType {
        return UniformType(coreType: kUTTypePNG)
    }

    public static var quickTimeImage: UniformType {
        return UniformType(coreType: kUTTypeQuickTimeImage)
    }

    public static var AppleICNS: UniformType {
        return UniformType(coreType: kUTTypeAppleICNS)
    }

    public static var bmp: UniformType {
        return UniformType(coreType: kUTTypeBMP)
    }

    public static var ico: UniformType {
        return UniformType(coreType: kUTTypeICO)
    }

    @available(iOS 8.0, *)
    public static var rawImage: UniformType {
        return UniformType(coreType: kUTTypeRawImage)
    }

    @available(iOS 8.0, *)
    public static var scalableVectorGraphics: UniformType {
        return UniformType(coreType: kUTTypeScalableVectorGraphics)
    }

    @available(iOS 9.1, *)
    public static var livePhoto: UniformType {
        return UniformType(coreType: kUTTypeLivePhoto)
    }
}

//MARK: -

extension UniformType {
    public static var audiovisualContent: UniformType {
        return UniformType(coreType: kUTTypeAudiovisualContent)
    }

    public static var movie: UniformType {
        return UniformType(coreType: kUTTypeMovie)
    }

    public static var video: UniformType {
        return UniformType(coreType: kUTTypeVideo)
    }

    public static var audio: UniformType {
        return UniformType(coreType: kUTTypeAudio)
    }

    public static var quickTimeMovie: UniformType {
        return UniformType(coreType: kUTTypeQuickTimeMovie)
    }

    public static var mpeg: UniformType {
        return UniformType(coreType: kUTTypeMPEG)
    }

    public static var mpeg2Video: UniformType {
        return UniformType(coreType: kUTTypeMPEG2Video)
    }

    public static var mpeg2TransportStream: UniformType {
        return UniformType(coreType: kUTTypeMPEG2TransportStream)
    }

    public static var mp3: UniformType {
        return UniformType(coreType: kUTTypeMP3)
    }

    public static var mpeg4: UniformType {
        return UniformType(coreType: kUTTypeMPEG4)
    }

    public static var mpeg4Audio: UniformType {
        return UniformType(coreType: kUTTypeMPEG4Audio)
    }

    public static var appleProtectedMPEG4Audio: UniformType {
        return UniformType(coreType: kUTTypeAppleProtectedMPEG4Audio)
    }

    @available(iOS 8.0, *)
    public static var appleProtectedMPEG4Video: UniformType {
        return UniformType(coreType: kUTTypeAppleProtectedMPEG4Video)
    }

    @available(iOS 8.0, *)
    public static var aviMovie: UniformType {
        return UniformType(coreType: kUTTypeAVIMovie)
    }

    @available(iOS 8.0, *)
    public static var audioInterchangeFileFormat: UniformType {
        return UniformType(coreType: kUTTypeAudioInterchangeFileFormat)
    }

    @available(iOS 8.0, *)
    public static var waveformAudio: UniformType {
        return UniformType(coreType: kUTTypeWaveformAudio)
    }

    @available(iOS 8.0, *)
    public static var midiAudio: UniformType {
        return UniformType(coreType: kUTTypeMIDIAudio)
    }
}

//MARK: -

extension UniformType {
    public static var playlist: UniformType {
        return UniformType(coreType: kUTTypePlaylist)
    }

    public static var m3upPlaylist: UniformType {
        return UniformType(coreType: kUTTypeM3UPlaylist)
    }
}

//MARK: -

extension UniformType {
    public static var folder: UniformType {
        return UniformType(coreType: kUTTypeFolder)
    }

    public static var volume: UniformType {
        return UniformType(coreType: kUTTypeVolume)
    }

    public static var package: UniformType {
        return UniformType(coreType: kUTTypePackage)
    }

    public static var bundle: UniformType {
        return UniformType(coreType: kUTTypeBundle)
    }

    @available(iOS 8.0, *)
    public static var pluginBundle: UniformType {
        return UniformType(coreType: kUTTypePluginBundle)
    }

    @available(iOS 8.0, *)
    public static var spotlightImporter: UniformType {
        return UniformType(coreType: kUTTypeSpotlightImporter)
    }

    @available(iOS 8.0, *)
    public static var quickLookGenerator: UniformType {
        return UniformType(coreType: kUTTypeQuickLookGenerator)
    }

    @available(iOS 8.0, *)
    public static var xpcService: UniformType {
        return UniformType(coreType: kUTTypeXPCService)
    }

    public static var framework: UniformType {
        return UniformType(coreType: kUTTypeFramework)
    }
}

//MARK: - Abstract executable types

extension UniformType {
    public static var application: UniformType {
        return UniformType(coreType: kUTTypeApplication)
    }

    public static var applicationBundle: UniformType {
        return UniformType(coreType: kUTTypeApplicationBundle)
    }

    public static var applicationFile: UniformType {
        return UniformType(coreType: kUTTypeApplicationFile)
    }

    @available(iOS 8.0, *)
    public static var unixExecutable: UniformType {
        return UniformType(coreType: kUTTypeUnixExecutable)
    }
}

//MARK: - Other platform binaries

@available(iOS 8.0, *)
extension UniformType {
    public static var windowsExecutable: UniformType {
        return UniformType(coreType: kUTTypeWindowsExecutable)
    }

    public static var javaClass: UniformType {
        return UniformType(coreType: kUTTypeJavaClass)
    }

    public static var javaArchive: UniformType {
        return UniformType(coreType: kUTTypeJavaArchive)
    }
}

//MARK: - Misc. binaries

@available(iOS 8.0, *)
extension UniformType {
    public static var preferencesPane: UniformType {
        return UniformType(coreType: kUTTypeSystemPreferencesPane)
    }
}

//MARK: -

@available(iOS 8.0, *)
extension UniformType {
    public static var gnuZipArchive: UniformType {
        return UniformType(coreType: kUTTypeGNUZipArchive)
    }

    public static var bzip2Archive: UniformType {
        return UniformType(coreType: kUTTypeBzip2Archive)
    }

    public static var zipArchive: UniformType {
        return UniformType(coreType: kUTTypeZipArchive)
    }
}

//MARK: -

@available(iOS 8.0, *)
extension UniformType {
    public static var spreadsheet: UniformType {
        return UniformType(coreType: kUTTypeSpreadsheet)
    }

    public static var presentation: UniformType {
        return UniformType(coreType: kUTTypePresentation)
    }

    public static var database: UniformType {
        return UniformType(coreType: kUTTypeDatabase)
    }
}

//MARK: -

extension UniformType {
    public static var vcard: UniformType {
        return UniformType(coreType: kUTTypeVCard)
    }

    @available(iOS 8.0, *)
    public static var todoItem: UniformType {
        return UniformType(coreType: kUTTypeToDoItem)
    }

    @available(iOS 8.0, *)
    public static var calendarEvent: UniformType {
        return UniformType(coreType: kUTTypeCalendarEvent)
    }

    @available(iOS 8.0, *)
    public static var emailMessage: UniformType {
        return UniformType(coreType: kUTTypeEmailMessage)
    }
}

//MARK: -

@available(iOS 8.0, *)
extension UniformType {
    public static var internetLocation: UniformType {
        return UniformType(coreType: kUTTypeInternetLocation)
    }
}

//MARK: -

extension UniformType {
    public static var inkText: UniformType {
        return UniformType(coreType: kUTTypeInkText)
    }

    @available(iOS 8.0, *)
    public static var font: UniformType {
        return UniformType(coreType: kUTTypeFont)
    }

    @available(iOS 8.0, *)
    public static var bookmark: UniformType {
        return UniformType(coreType: kUTTypeBookmark)
    }

    @available(iOS 8.0, *)
    public static var stereoscopicContent: UniformType {
        return UniformType(coreType: kUTType3DContent)
    }

    @available(iOS 8.0, *)
    public static var pkcs12: UniformType {
        return UniformType(coreType: kUTTypePKCS12)
    }

    @available(iOS 8.0, *)
    public static var x509Certificate: UniformType {
        return UniformType(coreType: kUTTypeX509Certificate)
    }

    @available(iOS 8.0, *)
    public static var electronicPublication: UniformType {
        return UniformType(coreType: kUTTypeElectronicPublication)
    }

    @available(iOS 8.0, *)
    public static var log: UniformType {
        return UniformType(coreType: kUTTypeLog)
    }
}
