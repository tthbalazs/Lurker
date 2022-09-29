//

import SwiftUI

@main
struct LurkerApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationView {
                SubredditListView(viewModel: .init())
            }
        }
    }
}
