//

import Combine
import SwiftUI

final class ListingViewViewModel: ObservableObject {
    @Published var listing: Listing?
    @Published var links: [Link] = []
    @Published var thumbnails: [String: UIImage] = [:]
    
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
                    self?.links = listing.children.compactMap(\.link)
                }
            })
            .store(in: &cancellables)
    }
    
    private var cancellables: Set<AnyCancellable> = .init()
    private let url: URL = URL(string: "https://www.reddit.com/r/all.json")!
}

struct ListingView: View {
    @ObservedObject var viewModel: ListingViewViewModel
    
    var body: some View {
        NavigationView {
            List(viewModel.links) { link in
                NavigationLink(
                    destination: ThingDetailView(
                        viewModel: ThingDetailViewModel(
                            link: link
                        )
                    ),
                    label: {
                        VStack(alignment: .leading) {
                            if let thumbnailUrl = link.thumbnailUrl {
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
                            Text(link.title ?? "")
                                .font(.headline)
                            HStack {
                                Text(link.subreddit ?? "")
                                    .foregroundColor(.accentColor)
                                    .font(.caption)
                                Spacer()
                                Text("\(link.ups ?? 0)")
                                    .foregroundColor(.orange)
                                    .monospacedDigit()
                            }
                        }
                    }
                )
                .listRowSeparator(.hidden)
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
        ListingView(
            viewModel: ListingViewViewModel()
        )
    }
}
