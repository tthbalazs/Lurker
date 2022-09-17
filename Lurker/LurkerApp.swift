//

import SwiftUI

@main
struct LurkerApp: App {
    var body: some Scene {
        WindowGroup {
            ListingView(viewModel: .init())
        }
    }
}
