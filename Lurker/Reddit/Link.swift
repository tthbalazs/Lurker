//

import Foundation

struct Link: Decodable, Identifiable, Hashable {
    enum CodingKeys: String, CodingKey {
        case subreddit
        case title
        case id
        case thumbnail
        case thumbnailHeight = "thumbnail_height"
        case ups
    }
    
    let id: String
    let title: String?
    let subreddit: String?
    let thumbnail: String?
    let thumbnailHeight: CGFloat?
    let ups: Int?
    
    // MARK: - Init methods
    
    init(from decoder: Decoder) throws {
        let superContainer = try decoder.container(keyedBy: Thing.CodingKeys.self)
        let container = try superContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .data)
        
        self.id = try container.decode(String.self, forKey: .id)
        self.title = try container.decodeIfPresent(String.self, forKey: .title)
        self.subreddit = try container.decodeIfPresent(String.self, forKey: .subreddit)
        self.thumbnail = try container.decodeIfPresent(String.self, forKey: .thumbnail)
        self.thumbnailHeight = try container.decodeIfPresent(CGFloat.self, forKey: .thumbnailHeight)
        self.ups = try container.decodeIfPresent(Int.self, forKey: .ups)
    }
    
    init(
        id: String,
        title: String? = nil,
        subreddit: String? = nil,
        thumbnail: String? = nil,
        thumbnailHeight: CGFloat? = nil,
        ups: Int? = nil
    ) {
        self.id = id
        self.title = title
        self.subreddit = subreddit
        self.thumbnail = thumbnail
        self.thumbnailHeight = thumbnailHeight
        self.ups = ups
    }
    
    // MARK: - Public
    
    var thumbnailUrl: URL? {
        guard let thumbnail else {
            return nil
        }
        
        return URL(string: thumbnail)
    }
}
