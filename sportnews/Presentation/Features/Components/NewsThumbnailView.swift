import Kingfisher
import SwiftUI
import UIKit

struct NewsThumbnailView: View {
    let imageUrl: String
    let blurHash: String?
    var fallbackColor: Color = Color.gray.opacity(0.2)
    var targetSize: CGSize? = nil

    var body: some View {
        Group {
            if let url = URL(string: imageUrl), !imageUrl.isEmpty {
                KFImage.url(url)
                    .placeholder { blurHashPlaceholder }
                    .setProcessor(imageProcessor)
                    .fade(duration: 0.15)
                    .resizable()
                    .scaledToFill()
            } else {
                blurHashPlaceholder
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipped()
    }

    private var imageProcessor: any ImageProcessor {
        guard let targetSize else { return DefaultImageProcessor.default }

        let scale = UIScreen.main.scale
        return DownsamplingImageProcessor(
            size: CGSize(
                width: targetSize.width * scale,
                height: targetSize.height * scale
            )
        )
    }

    @ViewBuilder
    private var blurHashPlaceholder: some View {
        if let uiImage = BlurHashCache.shared.image(for: blurHash) {
            Image(uiImage: uiImage)
                .interpolation(.low)
                .resizable()
                .scaledToFill()
        } else {
            fallbackColor
        }
    }
}
