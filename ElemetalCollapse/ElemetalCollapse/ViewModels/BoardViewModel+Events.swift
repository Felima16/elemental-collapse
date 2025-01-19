import SwiftUI
import RealityKit

extension BoardViewModel {
    func handleAnchorState(_ anchorState: SceneEvents.AnchoredStateChanged) {
        if anchorState.anchor.name == "boardAnchor" && anchorState.isAnchored {
            message = ""
        }
    }

    func handleUpdateState(_ updateEvent: SceneEvents.Update) {
        
    }
}
