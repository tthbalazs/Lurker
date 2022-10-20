//

import Combine
import SwiftUI

final class ListingViewViewModel: ObservableObject {
    @Published var listing: Listing?
    @Published var links: [Link] = []
    @Published var thumbnails: [String: UIImage] = [:]
    
    let subreddit: Subreddit
    
    init(subreddit: Subreddit) {
        self.subreddit = subreddit
    }
    
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
    
    private lazy var url: URL = URL(string: "https://www.reddit.com/\(subreddit.url).json")!
}

struct ListingView: View {
    @ObservedObject var viewModel: ListingViewViewModel
    
    var body: some View {
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
        .navigationTitle(viewModel.subreddit.displayNamePrefixed)
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
            viewModel: ListingViewViewModel(
                subreddit: Subreddit(
                    id: "",
                    title: "A subreddit for cute and cuddly pictures",
                    displayName: "aww",
                    publicDescription: "",
                    url: "/r/aww",
                    displayNamePrefixed: "/r/aww"
                )
            )
        ).preferredColorScheme(.dark)
    }
}
