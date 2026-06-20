import UIKit

final class BlurHashCache {
    static let shared = BlurHashCache()

    private let cache = NSCache<NSString, UIImage>()

    private init() {
        cache.countLimit = 200
    }

    func image(for blurHash: String?) -> UIImage? {
        guard let blurHash, !blurHash.isEmpty else { return nil }

        let key = blurHash as NSString
        if let cached = cache.object(forKey: key) {
            return cached
        }

        guard let image = UIImage(blurHash: blurHash, size: CGSize(width: 32, height: 32)) else {
            return nil
        }

        cache.setObject(image, forKey: key)
        return image
    }
}
