import Foundation

struct Article: Identifiable, Hashable {
    let pageid: Int
    let title: String
    let extract: String?
    let thumbnailURL: URL?

    var id: Int {
        pageid
    }
}
