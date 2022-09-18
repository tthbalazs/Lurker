//

import Combine
import SwiftUI

final class ListingViewViewModel: ObservableObject {
    @Published var listing: Listing?
    @Published var thumbnails: [String: UIImage] = [:]
    
    public init(imageProvider: any ImageProvider) {
        self.imageProvider = imageProvider
    }
    
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
    
    private var cancellables: Set<AnyCancellable> = .init()
    private let url: URL = URL(string: "https://www.reddit.com/r/all.json")!
    let imageProvider: any ImageProvider
}

struct ListingView: View {
    @ObservedObject var viewModel: ListingViewViewModel
    
    var body: some View {
        NavigationView {
            List(viewModel.listing?.children ?? []) { thing in
                NavigationLink(
                    destination: ThingDetailView(
                        viewModel: .init(
                            thing: thing,
                            imageProvider: viewModel.imageProvider
                        )
                    ),
                    label: {
                        HStack {
                            Image(uiImage: viewModel.thumbnails[thing.id] ?? thumbnailPlaceholder)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(
                                    maxWidth: 44,
                                    maxHeight: 44,
                                    alignment: .topLeading
                                )
                                .clipped()
                                .task {
                                    await viewModel.thumbnail(for: thing)
                                }
                            
                            VStack(alignment: .leading) {
                                Text(thing.title ?? "")
                                    .font(.headline)
                                HStack {
                                    Text(thing.subreddit ?? "")
                                        .foregroundColor(.accentColor)
                                        .font(.caption)
                                    Spacer()
                                    Text("\(thing.ups ?? 0)")
                                        .foregroundColor(.orange)
                                        .monospacedDigit()
                                }
                            }
                        }
                    }
                )
            }
            .navigationTitle("/r/all")
        }
        .listStyle(.plain)
        .onAppear(perform: viewModel.reload)
        .padding()
    }
    
    private let thumbnailPlaceholder: UIImage = UIImage(systemName: "photo")!
}

struct ListingView_Previews: PreviewProvider {
    static var previews: some View {
        ListingView(viewModel: .init(imageProvider: ImageProviderImpl()))
    }
}
