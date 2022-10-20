import SwiftUI

struct LinkView: View {
    var link: Link
    
    var body: some View {
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
}

struct LinkView_Previews: PreviewProvider {
    static var previews: some View {
        LinkView(
            link: Link(
                id: "xihs0h",
                title: "Look at this cat",
                subreddit: "aww",
                thumbnail: "https://b.thumbs.redditmedia.com/XjdzVIgg1Niu_6rMnghNAanLC9kUUp2o-gpE9p2mOmg.jpg",
                ups: 1337
            )
        )
    }
}
