import SwiftUI
import MultipeerConnectivity

@MainActor @Observable
final class AvailablePlayersViewModel {
    var gameNetwork: NetworkManager
    var isHost: Bool = false
    var gameInfo: GameInfo

    init(gameNetwork: NetworkManager) {
        self.gameNetwork = gameNetwork
        self.gameInfo = GameInfo(
            playerTurn: 0,
            GameState: .gameStart,
            score: 0
        )
    }

    var availablePlayers: [MCPeerID] {
        gameNetwork.availablePeers
    }

    func invatePeer(_ peer: MCPeerID) {
        gameNetwork.sendInvitationToPeer(peer)
    }

    func verifyPeerConnection(_ peer: MCPeerID) -> Bool {
        gameNetwork.connectedPlayers.contains(peer)
    }

    func starGame() {
        gameNetwork.sendGameInfo(gameInfo)
        gameNetwork.isPlayingGame = true
    }
}
