public enum ImageFormat: String {
    case heif
    case jpeg
}

extension ImageFormat: CaseIterable, Hashable, Codable {}

extension ImageFormat {

    public var uti: String {
        switch self {
        case .heif: return "public.heic"  // Note: heic, not heif!
        case .jpeg: return "public.jpeg"
        }
    }

    public var fileExtension: String {
        rawValue
    }

    public var displayString: String {
        rawValue.uppercased()
    }
}
