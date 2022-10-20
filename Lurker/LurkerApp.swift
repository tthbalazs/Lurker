//

import SwiftUI

@main
struct LurkerApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationView {
                List {
                    NavigationLink("Reddit", destination: SubredditListView(viewModel: .init()))
                    NavigationLink("Hacker News", destination: TopStoriesView(viewModel: .init()))
                }
                .navigationTitle("Choose a feed")
            }
        }
    }
}
