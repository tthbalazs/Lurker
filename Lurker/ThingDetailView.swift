//

import SwiftUI

struct ThingDetailView: View {
    var thing: Thing
    
    var body: some View {
        VStack {
            Text(thing.subreddit ?? "")
        }
        .navigationTitle(thing.title ?? "") // This is way too long
    }
}

struct ThingDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ThingDetailView(thing: .test)
    }
}
