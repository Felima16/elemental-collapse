import SwiftUI
import RealityKit

extension BoardViewModel {
    func handleAnchorState(_ anchorState: SceneEvents.AnchoredStateChanged) {
        if anchorState.anchor.name == "boardAnchor" && anchorState.isAnchored {
            print("### Board is anchored <<<")
            message = "Board Ready"
                gameInfo.GameState = .isPlaying
                gameNetwork.sendGameInfo(gameInfo)

            if !isHostGame {
                board?.removeFromParent()
            } else {
                Task {
                    do {
                        try await createFirstTree()
                    } catch {
                        print("Error loading content: \(error)")
                    }
                }
            }
        }
    }

    func handleUpdateState(_ updateEvent: SceneEvents.Update) {
        
    }
}
