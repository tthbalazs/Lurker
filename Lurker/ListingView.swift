//

import Combine
import SwiftUI

final class ListingViewViewModel: ObservableObject {
    @Published var listing: Listing?
    @Published var images: [String: Data] = [:]
    
    func reload() {
        URLSession(configuration: .default)
            .dataTaskPublisher(for: url)
            .tryMap { element -> Data in
                guard let httpResponse = element.response as? HTTPURLResponse,
                      httpResponse.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                return element.data
            }
            .decode(type: Listing.self, decoder: JSONDecoder())
            .sink(receiveCompletion: { _ in
            }, receiveValue: { [weak self] listing in
                DispatchQueue.main.async {
                    self?.listing = listing
                }
            })
            .store(in: &cancellables)
    }
    
    func loadImage(for thing: Thing) {
        if images[thing.id] != nil {
            return
        }
        
        guard let thumbnailUrl = thing.thumbnailUrl else { return }
        
        URLSession(configuration: .default)
            .dataTaskPublisher(for: thumbnailUrl)
            .tryMap { element -> Data in
                guard let httpResponse = element.response as? HTTPURLResponse,
                      httpResponse.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                return element.data
            }
            .sink(
                receiveCompletion: { _ in
                },
                receiveValue: { data in
                    DispatchQueue.main.async {
                        self.images[thing.id] = data
                    }
                }
            )
            .store(in: &cancellables)
    }
    
    private var cancellables: Set<AnyCancellable> = .init()
    private let url: URL = URL(string: "https://www.reddit.com/r/all.json")!
}

struct ListingView: View {
    @ObservedObject var viewModel: ListingViewViewModel
    
    var body: some View {
        NavigationView {
            List(viewModel.listing?.children ?? []) { thing in
                NavigationLink(
                    destination: ThingDetailView(thing: thing),
                    label: {
                        HStack {
                            if
                                let imageData = viewModel.images[thing.id],
                                let image = UIImage(data: imageData) {
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(
                                        maxWidth: 44,
                                        maxHeight: 44,
                                        alignment: .topLeading
                                    )
                                    .clipped()
                            }
                            VStack(alignment: .leading) {
                                Text(thing.title ?? "")
                                    .font(.headline)
                                Text(thing.subreddit ?? "")
                                    .font(.caption)
                            }
                        }
                        .onAppear(perform: { viewModel.loadImage(for: thing) })
                    }
                )
            }
            .navigationTitle("/r/all")
        }
        .listStyle(.plain)
        .onAppear(perform: viewModel.reload)
        .padding()
    }
}

struct ListingView_Previews: PreviewProvider {
    static var previews: some View {
        ListingView(viewModel: .init())
    }
}
