//

import Combine
import SwiftUI

final class ListingViewViewModel: ObservableObject {
    @Published var listing: Listing?
    @Published var links: [Link] = []
    @Published var thumbnails: [String: UIImage] = [:]
    
    func reload() async {
        do {
            let (data, _) = try await URLSession(configuration: .default).data(from: url)
            let listing = try JSONDecoder().decode(Listing.self, from: data)
            DispatchQueue.main.async {
                self.listing = listing
                self.links = listing.children.compactMap(\.link)
            }
        } catch {
            print(error)
        }
    }
    
    private let url: URL = URL(string: "https://www.reddit.com/r/all.json")!
}

struct ListingView: View {
    @ObservedObject var viewModel: ListingViewViewModel
    
    var body: some View {
        NavigationStack {
            List(viewModel.links) { link in
                NavigationLink {
                    ThingDetailView(
                        viewModel: ThingDetailViewModel(
                            link: link
                        )
                    )
                } label: {
                    LinkView(link: link)
                }
                .listRowSeparator(.hidden)
            }
            .navigationTitle("/r/all")
        }
        .refreshable(action: {
            await viewModel.reload()
        })
        .listStyle(.plain)
        .task {
            await viewModel.reload()
        }
    }
}

struct ListingView_Previews: PreviewProvider {
    static var previews: some View {
        ListingView(
            viewModel: ListingViewViewModel()
        )
    }
}
