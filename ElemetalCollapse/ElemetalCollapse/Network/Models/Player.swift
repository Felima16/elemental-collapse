import Foundation

struct Player: Codable, Identifiable {
    var id = UUID()
    var name: String
    var score: Int
    var isHost: Bool
    var turnPosition: Int
}
