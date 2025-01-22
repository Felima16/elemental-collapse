import Foundation

struct GameInfo: Codable {
    var playerTurn: Int
    var GameState: GameState
    var score: Int
    var placeholderPieces: [Piece] = []
}

enum GameState: Codable {
    case gameStart
    case isPlaying
    case gameOver
}

struct Piece: Codable, Identifiable {
    var id = UUID()
    var elemental: ElementalType
}

enum ElementalType: Codable {
    case fire
    case water
    case earth
    case air
    case tree
    case treeWithFire
}
