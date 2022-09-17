//

import Combine
import SwiftUI

class ThingDetailViewModel: ObservableObject {
    @Published var comments: [Comment] = []
    
    init(thing: Thing) {
        self.thing = thing
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
    
    let thing: Thing
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
        VStack(alignment: .leading) {
            Text(viewModel.thing.subreddit ?? "")
                .padding([.leading])
//            if let image = image {
//                Image(uiImage: image)
//            }
            List(viewModel.comments) { comment in
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
        .onAppear(perform: viewModel.loadComments)
        .navigationTitle(viewModel.thing.title ?? "") // This is way too long
    }
}

struct ThingDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ThingDetailView(viewModel: .init(thing: .test))
    }
}
