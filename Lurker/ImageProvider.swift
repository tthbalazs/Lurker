//

import Combine
import Foundation
import UIKit

protocol ImageProvider: ObservableObject {
    func loadImage(for url: URL) async -> UIImage?
}

class ImageProviderImpl: ImageProvider {
    func loadImage(for url: URL) async -> UIImage? {
        if let imageData = images[url] {
            return imageData
        }
        
        do {
            let (data, _) = try await URLSession(configuration: .default).data(from: url)
            let image = UIImage(data: data)
            queue.async {
                self.images[url] = image
            }
            return image
        } catch {
            // TODO: Handler errors later
            return nil
        }
    }
    
    private var images: [URL: UIImage] = [:]
    private let queue: DispatchQueue = DispatchQueue(
        label: "imageProviderQueue",
        qos: .userInitiated
    )
}
