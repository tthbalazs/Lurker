//

import Combine
import Foundation
import UIKit

protocol ImageProvider: ObservableObject {
    typealias DataLoader = (URL) async throws -> (Data, URLResponse)
    func loadImage(for url: URL) async -> UIImage?
}

// MARK: - Implementation

class ImageProviderImpl: ImageProvider {
    init(
        cache: [URL: UIImage] = [:],
        dataLoader:  @escaping DataLoader = URLSession(configuration: .default).data(from:)
    ) {
        self.cache = cache
        self.dataLoader = dataLoader
    }
    
    func loadImage(for url: URL) async -> UIImage? {
        if let imageData = cache[url] {
            return imageData
        }
        
        do {
            let (data, _) = try await dataLoader(url)
            let image = UIImage(data: data)
            queue.async {
                self.cache[url] = image
            }
            return image
        } catch {
            // TODO: Handler errors later
            return nil
        }
    }
    
    private var dataLoader: (URL) async throws -> (Data, URLResponse)
    private var cache: [URL: UIImage] = [:]
    private let queue: DispatchQueue = DispatchQueue(
        label: "imageProviderQueue",
        qos: .userInitiated
    )
}
