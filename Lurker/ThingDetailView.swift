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
    
    func loadComments() async {
        guard
            let subreddit = link.subreddit,
            let commentUrl = URL(string: "https://www.reddit.com/r/\(subreddit)/comments/\(link.id).json")
        else {
            return
        }
        
        do {
            let (data, _) = try await URLSession(configuration: .default).data(from: commentUrl)
            let listings = try JSONDecoder().decode([Listing].self, from: data)
            DispatchQueue.main.async {
                self.listings = listings
                if listings.count >= 2 {
                    self.comments = listings[1].children.compactMap(\.comment)
                }
            }
        } catch {
            print(error)
        }
    }
    
    // MARK: - Private
    
    private var listings: [Listing] = []
}

struct ThingDetailView: View {
    @ObservedObject var viewModel: ThingDetailViewModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                LinkView(link: viewModel.link)
                    .padding([.bottom])
                ForEach(viewModel.comments) { comment in
                    CommentView(comment: comment)
                        .padding([.bottom])
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle(viewModel.link.title ?? "") // This is way too long
        .task {
            await viewModel.loadComments()
        }
    }
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
