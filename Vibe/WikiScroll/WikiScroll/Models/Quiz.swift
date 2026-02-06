import Foundation
import FoundationModels

@Generable
struct Quiz: Equatable {
    @Guide(.count(5))
    let questions: [QuizQuestion]
}
