import SwiftUI
import ARKit
import RealityKit
import RealityKitContent

@MainActor @Observable
final class BoardViewModel: NSObject {
    enum State {
        case tutorial
        case game
    }

    var gameNetwork: NetworkManager
    var imageClassifier: ImageClassifierManager
    var elementalPierceSelect: ElementalPiece?
    var message: String = ""

    var board: AnchorEntity?
    var arView: ARView = ARView.makeBoradARView(frame: .zero)

    var isPieceSelected = false
    @ObservationIgnored
    var state: State

    //game manager
    var players = [Player]()
    var gameInfo: GameInfo
    var isHostGame: Bool

    var pieceSize = SIMD3<Float>()

    init(
        gameNetwork: NetworkManager,
        state: State,
        isHostGame: Bool = false,
        gameInfo: GameInfo
    ) {
        self.imageClassifier = ImageClassifierManager()
        self.gameNetwork = gameNetwork
        self.state = state
        self.isHostGame = isHostGame
        self.gameInfo = gameInfo
        
        super.init()

        self.gameNetwork.delegate = self
        self.imageClassifier.delegate = self
        if isHostGame {
            startGame()
        }
    }

    func prepareBoard() async throws -> Entity {
        let board = try await Entity.makeBoard()

        message = "looking for table to board..."
        return board
    }

    func createFirstTree() async throws {
        let treeEntity = try await Entity.makeFirstTree()
        treeEntity.name = "treeEntity"
        let anchor = arView.scene.anchors.first { $0.name == "boardAnchor" }
        guard let anchor, anchor.findEntity(named: "treeEntity") == nil else {
            return
        }
        anchor.addChild(treeEntity)

        for index in 0...3 {
            if let placeholder = try await Entity.makePlaceholderPiece() {
                let placeholderPiece = Piece(elemental: .tree)
                gameInfo.placeholderPieces.append(placeholderPiece)

                placeholder.generateCollisionShapes(recursive: true)
                placeholder.name = placeholderPiece.id.uuidString

                switch index {
                case 0:
                    pieceSize = placeholder.model!.mesh.bounds.extents
                    placeholder.position.x = -pieceSize.x
                case 1:
                    placeholder.position.x = pieceSize.x
                case 2:
                    placeholder.position.z = -pieceSize.y
                case 3:
                    placeholder.position.z = pieceSize.y
                default:
                    break
                }
                anchor.addChild(placeholder)
            }
        }
        gameNetwork.sendGameInfo(gameInfo)
    }

    func setBufferFrame(_ buffer : CVPixelBuffer) async {
        await imageClassifier.visionRequest(buffer)
    }

    func verifyIsMyTurn() -> Bool {
        let me = players.first { $0.name == gameNetwork.myName }
        return me?.turnPosition == gameInfo.playerTurn
    }

    @objc func selected(recognizer: UITapGestureRecognizer) {
        guard elementalPierceSelect != nil else { return }
        // Obtain the location of a tap or touch gesture
        let tapLocation = recognizer.location(in: arView)

        if let entity = arView.entity(at: tapLocation) as? ModelEntity {
            print("### Tapped on: \(entity.name)")
            Task {
                await handlePieceSelection(entity)
            }
        }
    }

    private func handlePieceSelection(_ entity: ModelEntity) async {
        guard
            let placeholder = gameInfo.placeholderPieces.first (where: { $0.id.uuidString == entity.name }),
            let elementalPiece = elementalPierceSelect else {
            return
        }
        Task {
            switch (placeholder.elemental, elementalPiece) {
                    //        case (.tree, .fire):
            case (.tree, .water):
                await createSpring(entity: entity)
                    //        case (.tree, .earth):
                    //        case (.tree, .air):
            default:
                break
            }
        }
    }

    private func createSpring(entity: ModelEntity) async {
        Task {
            let entitySpring = try await Entity.makeSpring()
            entitySpring.position = entity.position
            let anchor = arView.scene.anchors.first { $0.name == "boardAnchor" }
            anchor?.addChild(entitySpring)

            entity.removeFromParent()
            gameInfo.placeholderPieces.removeAll { $0.id.uuidString == entity.name }

//            if let placeholder = try await Entity.makePlaceholderPiece() {
//                let placeholderPiece = Piece(elemental: .water)
//                placeholder.generateCollisionShapes(recursive: true)
//                placeholder.name = placeholderPiece.id.uuidString
//                placeholder.position.x = entity.position.x + pieceSize.x
//                if let me = players.firstIndex (where: { $0.name == gameNetwork.myName }) {
//                    players[me].score += 1
//                }
//                gameInfo.placeholderPieces.append(placeholderPiece)
//                anchor?.addChild(placeholder)
//                await finishTurn()
//            }

            if let me = players.firstIndex (where: { $0.name == gameNetwork.myName }) {
                players[me].score += 1
            }
            await finishTurn()
        }
    }

    private func finishTurn() async {
        elementalPierceSelect = nil
        gameInfo.playerTurn += 1

        if gameInfo.playerTurn == players.count {
            gameInfo.playerTurn = 0
        }
        gameNetwork.sendPLayerList(players)
        gameNetwork.sendGameInfo(gameInfo)
    }

    private func startGame() {
        print("##### startGame")

        var turns: [Int] = []
        let turnPosition = randomTurnPosition(turns)
        turns.append(turnPosition)
        let me = Player(
            name: gameNetwork.myName,
            score: 0,
            isHost: true,
            turnPosition: turnPosition
        )
        players.append(me)
        for peer in gameNetwork.availablePeers {
            let turnPosition = randomTurnPosition(turns)
            turns.append(turnPosition)
            let player = Player(
                name: peer.displayName,
                score: 0,
                isHost: false,
                turnPosition: turnPosition
            )
            players.append(player)
        }
        gameNetwork.sendPLayerList(players)
    }

    private func randomTurnPosition(_ turns: [Int]) -> Int {
        var isDraw = true
        while isDraw {
            let position = Int.random(in: 0...gameNetwork.connectedPlayers.count)
            if !turns.contains(position) {
                isDraw = false
                return position
            }
        }
    }
}

extension BoardViewModel: ARSessionDelegate {
    nonisolated func session(_ session: ARSession, didUpdate frame: ARFrame) {
        Task { @MainActor in
            guard isPieceSelected else { return }
            await setBufferFrame(frame.capturedImage)
            isPieceSelected = false
        }
    }

    nonisolated func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        Task { @MainActor in
            for anchor in anchors {
                if let participantAnchor = anchor as? ARParticipantAnchor {
                    let anchorEntity = AnchorEntity(anchor: participantAnchor)
                    arView.scene.addAnchor(anchorEntity)
                }
            }
        }
    }
}

extension BoardViewModel: ImageClassifierManagerDelegate {
    func pirceSelect(elementalPierceSelect: ElementalPiece) {
        self.elementalPierceSelect = elementalPierceSelect
        message = "\(elementalPierceSelect.rawValue) is selected"
    }
}

extension BoardViewModel: NetworkManagerDelegate {
    nonisolated func didReceivePlayers(_ players: [Player]) {
        Task { @MainActor in
            self.players = players
            print("##### didReceivePlayers \(players)")
        }
    }
    
    nonisolated func didReceiveGameInfo(_ gameInfo: GameInfo) {
        Task { @MainActor in
            self.gameInfo = gameInfo
            print("##### didReceiveGameInfo \(gameInfo)")
        }
    }
}
