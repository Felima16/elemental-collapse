import RealityKit
import RealityKitContent

extension Entity {
    static func makeBoard() async throws -> Entity {
        let board = try await Entity(named: "Board", in: realityKitContentBundle)
        return board
    }
}
