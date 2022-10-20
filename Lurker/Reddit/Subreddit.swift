import Foundation

struct Subreddit: Decodable, Identifiable, Hashable, Comparable {
    init(
        id: String,
        title: String,
        displayName: String,
        publicDescription: String,
        iconImage: URL? = nil,
        url: String,
        displayNamePrefixed: String
    ) {
        self.id = id
        self.title = title
        self.displayName = displayName
        self.publicDescription = publicDescription
        self.iconImage = iconImage
        self.url = url
        self.displayNamePrefixed = displayNamePrefixed
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case displayName = "display_name"
        case publicDescription = "public_description"
        case iconImage = "icon_img"
        case url
        case displayNamePrefixed = "display_name_prefixed"
    }
     
    let id: String
    let title: String
    let displayName: String
    let publicDescription: String
    let iconImage: URL?
    let url: String
    let displayNamePrefixed: String
    
    // MARK: - Init methods
    
    init(from decoder: Decoder) throws {
        let superContainer = try decoder.container(keyedBy: Thing.CodingKeys.self)
        let container = try superContainer.nestedContainer(
            keyedBy: CodingKeys.self,
            forKey: .data
        )
        self.id = try container.decode(String.self, forKey: .id)
        self.title = try container.decode(String.self, forKey: .title)
        self.displayName = try container.decode(String.self, forKey: .displayName)
        self.publicDescription = try container.decode(String.self, forKey: .publicDescription)
        let iconImg = try container.decodeIfPresent(String.self, forKey: .iconImage)
        self.iconImage = URL(string: iconImg ?? "")
        self.url = try container.decode(String.self, forKey: .url)
        self.displayNamePrefixed = try container.decode(String.self, forKey: .displayNamePrefixed)
    }
    
    static func < (lhs: Subreddit, rhs: Subreddit) -> Bool {
        lhs.displayName.lowercased() < rhs.displayName.lowercased()
    }
}
