import Foundation

/// A message part that can be added to Multipart containers.
public struct Part<T: Collection>: MultipartEntity where T.Element == UInt8 {

    public var content: T
    
    /// Message headers that apply to this specific part
    public var headers: [MessageHeader] = []

    public init(content: T) {
        self.content = content
    }

    public func write<D>(to body: inout D) where D: MutableDataProtocol {
        body.append(contentsOf: content)
    }
}

// Helper functions for quick generation of "multipart/form-data" parts.
extension Part where T == String.UTF8View {
    
    /// A "multipart/form-data" part containing a form field and its corresponding value, which can be added to
    /// Multipart containers.
    /// - Parameter name: Field name from the form.
    /// - Parameter value: Value from the form field.
    public init(name: String, value: String) {
        content = value.utf8
        setValue("form-data", forHeaderField: "Content-Disposition")
        setAttribute(attribute: "name", value: name, forHeaderField: "Content-Disposition")
        setAttribute(attribute: "charset", value: "utf-8", forHeaderField: "Content-Type")
    }
}

extension Part where T == Data {
    
    /// A "multipart/form-data" part containing file data, which can be added to Multipart containers.
    /// - Parameter name: Field name from the form.
    /// - Parameter fileData: Complete contents of the file.
    /// - Parameter fileName: Original local file name of the file.
    /// - Parameter contentType: MIME Content-Type specifying the nature of the data.
    public init(name: String, fileData: Data, fileName: String? = nil,
                contentType: String? = nil) {
        content = fileData
        setValue("form-data", forHeaderField: "Content-Disposition")
        setAttribute(attribute: "name", value: name, forHeaderField: "Content-Disposition")
        if let fileName = fileName {
            setAttribute(attribute: "filename", value: fileName, forHeaderField: "Content-Disposition")
        }
        if let contentType = contentType {
            setValue(contentType, forHeaderField: "Content-Type")
        }
    }
}

extension Part {
    public var description: String {
        var descriptionString = self.headers.string() + Multipart.CRLF
        if T.self == String.UTF8View.self {
            descriptionString.append(String(content as! String.UTF8View))
        } else {
            descriptionString.append("(\(content.count) bytes)")
        }
        return descriptionString
    }
}
