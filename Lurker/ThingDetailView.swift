//

import Combine
import SwiftUI
import UIKit

class ThingDetailViewModel: ObservableObject {
    @Published var comments: [Comment] = []
    @Published var thumbnails: [String: UIImage] = [:]
    
    let thing: Thing
    
    init(thing: Thing, imageProvider: any ImageProvider) {
        self.thing = thing
        self.imageProvider = imageProvider
    }
    
    func loadComments() {
        guard
            let subreddit = thing.subreddit,
            let commentUrl = URL(string: "https://www.reddit.com/r/\(subreddit)/comments/\(thing.id).json")
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
            .decode(type: [CommentsListing].self, decoder: JSONDecoder())
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] listings in
                    DispatchQueue.main.async {
                        self?.listings = listings
                    }
                }
            )
    }
    
    func thumbnail(for thing: Thing) async {
        guard let thumbnailUrl = thing.thumbnailUrl else {
            return
        }
        
        if let image = await imageProvider.loadImage(for: thumbnailUrl) {
            DispatchQueue.main.async {
                self.thumbnails[thing.id] = image
            }
        }
    }
    
    // MARK: - Private
    
    private let imageProvider: any ImageProvider
    
    private var listings: [CommentsListing] = [] {
        didSet {
            guard listings.count >= 2 else {
                return
            }
            
            comments = listings[1].children
        }
    }
    private var cancellable: AnyCancellable?
}

struct ThingDetailView: View {
    @ObservedObject var viewModel: ThingDetailViewModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text(viewModel.thing.subreddit ?? "")
                    .padding([.leading])
                Image(uiImage: viewModel.thumbnails[viewModel.thing.id] ?? thumbnailPlaceholder)
                    .task {
                        await viewModel.thumbnail(for: viewModel.thing)
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
        .navigationTitle(viewModel.thing.title ?? "") // This is way too long
    }
    
    private let thumbnailPlaceholder: UIImage = UIImage(systemName: "photo")!
}

struct ThingDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ThingDetailView(
            viewModel: .init(
                thing: .test,
                imageProvider: ImageProviderImpl()
            )
        )
    }
}
