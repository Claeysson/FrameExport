import CoreGraphics

extension FrameExport {
    
    public struct ImageEncoding {
        let format: ImageFormat
        let compressionQuality: Double
        let metadata: CGImage.Metadata?
        
        
        public init(format: ImageFormat, compressionQuality: Double, metadata: CGImage.Metadata = CGImage.metadata(for: nil, location: nil)) {
            self.format = format
            self.compressionQuality = compressionQuality
            self.metadata = metadata
        }
    }
}
