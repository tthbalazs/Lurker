//

import SwiftUI

struct CommentView: View {
    var comment: Comment
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(comment.author ?? "")
                    .foregroundColor(.accentColor)
                    .font(.subheadline)
                Spacer()
                Text("\(comment.ups ?? 0)")
                    .foregroundColor(.orange)
                    .monospacedDigit()
            }
            Text(comment.body ?? "")
        }
    }
}

struct CommentView_Previews: PreviewProvider {
    static var previews: some View {
        CommentView(
            comment: Comment(
                id: "",
                body: "This is a comment",
                author: "Author",
                ups: 13
            )
        )
    }
}
