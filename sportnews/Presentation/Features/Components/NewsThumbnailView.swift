import SwiftUI

struct NewsThumbnailView: View {
    let imageUrl: String
    let blurHash: String?
    var contentMode: ContentMode = .fill
    var fallbackColor: Color = Color.gray.opacity(0.2)

    var body: some View {
        AsyncImage(url: URL(string: imageUrl)) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
            case .empty, .failure:
                blurHashPlaceholder
            @unknown default:
                blurHashPlaceholder
            }
        }
    }

    @ViewBuilder
    private var blurHashPlaceholder: some View {
        if let uiImage = BlurHashCache.shared.image(for: blurHash) {
            Image(uiImage: uiImage)
                .interpolation(.low)
                .resizable()
                .aspectRatio(contentMode: contentMode)
        } else {
            fallbackColor
        }
    }
}
