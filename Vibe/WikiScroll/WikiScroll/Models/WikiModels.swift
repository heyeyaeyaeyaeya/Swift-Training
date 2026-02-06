import Foundation

struct WikiResponse: Decodable {
    let query: WikiQuery?
    let continueInfo: WikiContinue?

    private enum CodingKeys: String, CodingKey {
        case query
        case continueInfo = "continue"
    }
}

struct WikiQuery: Decodable {
    let pages: [WikiPage]
}

struct WikiPage: Decodable {
    let pageid: Int
    let title: String
    let extract: String?
    let thumbnail: WikiThumbnail?
}

struct WikiThumbnail: Decodable {
    let url: URL

    private enum CodingKeys: String, CodingKey {
        case url = "source"
    }
}

struct WikiContinue: Decodable {
    let grncontinue: String?
    let continueValue: String?

    private enum CodingKeys: String, CodingKey {
        case grncontinue
        case continueValue = "continue"
    }
}

struct WikiParseResponse: Decodable {
    let parse: WikiParse?
}

struct WikiParse: Decodable {
    let title: String?
    let pageid: Int?
    let text: WikiParseText?
}

struct WikiParseText: Decodable {
    let html: String

    private enum CodingKeys: String, CodingKey {
        case html = "*"
    }
}
