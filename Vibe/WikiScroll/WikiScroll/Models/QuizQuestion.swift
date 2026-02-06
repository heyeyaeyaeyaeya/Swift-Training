import Foundation
import FoundationModels

@Generable
struct QuizQuestion: Equatable {
    let question: String
    @Guide(.count(4))
    let options: [String]
    @Guide(description: "Index of the correct option from 0 to 3.")
    let correctIndex: Int
}
