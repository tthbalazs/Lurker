//

import Foundation

struct Thing: Codable, Identifiable {
    init(
        id: String,
        title: String? = nil,
        subreddit: String? = nil,
        thumbnail: String? = nil,
        ups: Int? = 0
    ) {
        self.title = title
        self.subreddit = subreddit
        self.thumbnail = thumbnail
        self.id = id
        self.ups = ups
    }
    
    enum ContainerCodingKeys: String, CodingKey {
        case kind
        case data
    }
    
    enum CodingKeys: String, CodingKey {
        case subreddit
        case title
        case id
        case thumbnail
        case ups
    }
    
    let id: String
    let title: String?
    let subreddit: String?
    let thumbnail: String?
    let ups: Int?
    
    var thumbnailUrl: URL? {
        guard let thumbnail = self.thumbnail else { return nil }
        return URL(string: thumbnail)
    }
    
    init(from decoder: Decoder) throws {
        let parentContainer = try decoder.container(keyedBy: ContainerCodingKeys.self)
        let container = try parentContainer.nestedContainer(
            keyedBy: CodingKeys.self,
            forKey: .data
        )
        
        self.id = try container.decode(String.self, forKey: .id)
        
        self.subreddit = try container.decodeIfPresent(String.self, forKey: .subreddit)
        self.title = try container.decodeIfPresent(String.self, forKey: .title)
        self.thumbnail = try container.decodeIfPresent(String.self, forKey: .thumbnail)
        self.ups = try container.decodeIfPresent(Int.self, forKey: .ups)
    }
}

extension Thing {
    // https://www.reddit.com/r/Wellthatsucks/comments/xgoj2f.json
    static let test: Thing = .init(
        id: "xgoj2f",
        title: "We're testing stuff",
        subreddit: "Wellthatsucks",
        thumbnail: "",
        ups: 1337
    )
}
