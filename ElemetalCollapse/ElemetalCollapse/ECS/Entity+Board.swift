import RealityKit
import RealityKitContent

extension Entity {
    static func makeBoard() async throws -> Entity {
        try await Entity(named: "Board", in: realityKitContentBundle)
    }

    static func makeFirstTree() async throws -> Entity {
        try await Entity(named: "FirstTree", in: realityKitContentBundle)
    }

    static func makeSpring() async throws -> Entity {
        try await Entity(named: "spring", in: realityKitContentBundle)
    }

    static func makePlaceholderPiece() async throws -> ModelEntity? {
        let scene = try await Entity(named: "Piece", in: realityKitContentBundle)
        return scene.children.first?.findEntity(named: "Cube_006") as? ModelEntity
    }
}
