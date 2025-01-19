import SwiftUI
import RealityKit
import RealityKitContent

@MainActor @Observable
final class BoardViewModel {
    enum State {
        case tutorial
        case game
    }

    var gameNetwork: NetworkManager
    var message: String = ""

    var board: Entity?
    @ObservationIgnored var state: State

    var myAvatar: Image {
        Image(systemName: "person.crop.circle")
    }

    var otherAvatar: Image {
        Image(systemName: "person.crop.circle")
    }

    init(
        gameNetwork: NetworkManager,
        state: State
    ) {
        self.gameNetwork = gameNetwork
        self.state = state
    }

    func prepareBoard() async throws -> Entity {
        let board = try await Entity.makeBoard()

        self.board = board
        message = "looking for table to board..."
        return board
    }
}
