//

import Combine
import SwiftUI
import UIKit

class ThingDetailViewModel: ObservableObject {
    @Published var comments: [Comment] = []
    @Published var thumbnails: [String: UIImage] = [:]
    
    let link: Link
    
    init(link: Link) {
        self.link = link
    }
    
    func loadComments() {
        guard
            let subreddit = link.subreddit,
            let commentUrl = URL(string: "https://www.reddit.com/r/\(subreddit)/comments/\(link.id).json")
        else {
            return
        }
                
        cancellable = URLSession(configuration: .default)
            .dataTaskPublisher(for: commentUrl)
            .tryMap { element -> Data in
                guard let httpResponse = element.response as? HTTPURLResponse,
                      httpResponse.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                return element.data
            }
            .decode(type: [Listing].self, decoder: JSONDecoder())
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] listings in
                    DispatchQueue.main.async {
                        self?.listings = listings
                    }
                }
            )
    }
    
    // MARK: - Private
    
    private var listings: [Listing] = [] {
        didSet {
            guard listings.count >= 2 else {
                return
            }
            
            comments = listings[1].children.compactMap(\.comment)
        }
    }
    private var cancellable: AnyCancellable?
}

struct ThingDetailView: View {
    @ObservedObject var viewModel: ThingDetailViewModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text(viewModel.link.subreddit ?? "")
                    .padding([.leading])
                if let thumbnailUrl = viewModel.link.thumbnailUrl {
                    AsyncImage(url: thumbnailUrl) { phase in
                        if let image = phase.image {
                            image.resizable()
                        } else if phase.error != nil {
                        } else {
                            ProgressView()
                        }
                    }
                    .aspectRatio(contentMode: .fit)
                }
                ForEach(viewModel.comments) { comment in
                    VStack(alignment: .leading) {
                        HStack {
                            Text(comment.author ?? "")
                                .foregroundColor(.accentColor)
                                .font(.subheadline)
                            Spacer()
                            Text("\(comment.ups ?? 0)")
                                .foregroundColor(.orange)
                                .monospacedDigit()
                        }
                        Text(comment.body ?? "")
                    }
                }
                .listStyle(.plain)
            }
        }
        .onAppear(perform: viewModel.loadComments)
        .navigationTitle(viewModel.link.title ?? "") // This is way too long
    }
    
    private let thumbnailPlaceholder: UIImage = UIImage(systemName: "photo")!
}

struct ThingDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ThingDetailView(
            viewModel: .init(
                link: Link(
                    id: "xihs0h",
                    thumbnail: "https://b.thumbs.redditmedia.com/XjdzVIgg1Niu_6rMnghNAanLC9kUUp2o-gpE9p2mOmg.jpg"
                )
            )
        )
    }
}
