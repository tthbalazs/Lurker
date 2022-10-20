import SwiftUI

final class SubredditListViewModel: ObservableObject {
    @Published var subreddits: [Subreddit] = []
    @Published var filteredSubreddits: [Subreddit] = []
    
    @Published var listing: Listing?
    @Published var searchTerm: String = ""
    
    func search() {
        let search = searchTerm.lowercased()
        if search.isEmpty {
            filteredSubreddits = subreddits
            return
        }
        
        filteredSubreddits = subreddits
            .filter {
                $0.displayName.hasPrefix(search)
            }
    }
    
    func reload() async {
        do {
            let (data, _) = try await URLSession(configuration: .default).data(from: url)
            let listing = try JSONDecoder().decode(Listing.self, from: data)
            DispatchQueue.main.async {
                self.listing = listing
                self.subreddits = listing.children.compactMap(\.subreddit)
                self.filteredSubreddits = self.subreddits
            }
        } catch {
            print(error)
        }
    }
    
    private let url: URL = URL(string: "https://www.reddit.com/subreddits/default.json")!
}

struct SubredditListView: View {
    @ObservedObject var viewModel: SubredditListViewModel
    
    var body: some View {
        List(viewModel.filteredSubreddits) { subreddit in
            NavigationLink {
                ListingView(viewModel: .init(subreddit: subreddit))
            } label: {
                HStack {
                    if let iconImage = subreddit.iconImage {
                        AsyncImage(url: iconImage) { phase in
                            if let image = phase.image {
                                image.resizable()
                            } else if phase.error != nil {
                                Image(systemName: "photo")
                            } else {
                                ProgressView()
                            }
                        }
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24)
                    } else {
                        Image(systemName: "photo")
                            .frame(width: 24)
                    }
                    VStack(alignment: .leading, spacing: 6) {
                        Text(subreddit.displayNamePrefixed)
                            .font(.headline)
                            .bold()
                        Text(subreddit.publicDescription)
                            .font(.caption)
                    }
                }
            }
        }
        .refreshable {
            await viewModel.reload()
        }
        .searchable(text: $viewModel.searchTerm)
        .searchSuggestions {
            ForEach(viewModel.subreddits) { subreddit in
                Text(subreddit.displayName).searchCompletion(subreddit.displayName)
            }
        }
        .onSubmit(of: .search) {
            viewModel.search()
        }
        .listStyle(.plain)
        .navigationTitle("Subreddits")
        .task {
            await viewModel.reload()
        }
    }
}

struct SubredditListView_Previews: PreviewProvider {
    static var previews: some View {
        SubredditListView(
            viewModel: .init()
        ).preferredColorScheme(.dark)
    }
}
