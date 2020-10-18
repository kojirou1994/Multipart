import Foundation

fileprivate func randomASCIIString(length: Int, source: StaticString) -> String {
    assert(source.isASCII)
    var random = SystemRandomNumberGenerator()
    return source.withUTF8Buffer { buffer -> String in
        assert(!buffer.isEmpty)
        if #available(OSX 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *) {
            return String(unsafeUninitializedCapacity: length) { strBuffer -> Int in
                for index in strBuffer.indices {
                    strBuffer[index] = buffer.randomElement(using: &random).unsafelyUnwrapped
                }
                return length
            }
        } else {
            var string = ""
            string.reserveCapacity(length)
            for _ in 0..<length {
                string.append(Character(Unicode.Scalar(buffer.randomElement(using: &random).unsafelyUnwrapped)))
            }
            return string
        }
    }
}

fileprivate let boundaryAvailable: StaticString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"

public func randomBoundaryString(prefix: String = "--SwiftMultipart", ramdomLength: Int = 16) -> String {
    prefix + randomASCIIString(length: ramdomLength, source: boundaryAvailable)
}
