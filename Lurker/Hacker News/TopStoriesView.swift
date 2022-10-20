//

import SwiftUI

class TopStoriesViewModel: ObservableObject {
    @Published var stories: [Story] = []
    
    let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        return dateFormatter
    }()
    
    func reload() async {
        do {
            let (data, _) = try await URLSession(configuration: .default).data(from: url)
            let topStories = try JSONDecoder().decode(TopStories.self, from: data)
            self.topStories = topStories
             
            let topTenIds = Array(topStories.ids[0..<10])
            topTenIds.forEach {
                loadStory(id: $0)
            }
        } catch {
            print(error)
        }
    }
    
    func loadStory(id: Int) {
        let url = URL(string: "https://hacker-news.firebaseio.com/v0/item/\(id).json")!
        
        Task {
            do {
                let (data, _) = try await URLSession(configuration: .default).data(from: url)
                let story = try JSONDecoder().decode(Story.self, from: data)
                
                DispatchQueue.main.async {
                    self.stories.append(story)
                }
            } catch {
                print(error)
            }
        }
    }
    
    private var topStories: TopStories?
    private var url: URL = URL(string: "https://hacker-news.firebaseio.com/v0/topstories.json")!
}

struct TopStoriesView: View {
    @ObservedObject var viewModel: TopStoriesViewModel
    
    var body: some View {
        List(viewModel.stories) { story in
            VStack(alignment: .leading, spacing: 4) {
                Text(story.title)
                    .font(.headline)
                Text(story.url.host() ?? "")
                    .italic()
                HStack {
                    Spacer()
                    Text(viewModel.dateFormatter.string(from: story.date))
                        .font(.footnote)
                }
            }
            .padding([.top, .bottom])
            .onTapGesture {
                if UIApplication.shared.canOpenURL(story.url) {
                    UIApplication.shared.open(story.url)
                }
            }
        }
        .listStyle(.plain)
        .task {
            await viewModel.reload()
        }
        .navigationTitle("Top Stories")
    }
}

struct TopStoriesView_Previews: PreviewProvider {
    static var previews: some View {
        TopStoriesView(viewModel: .init())
    }
}
