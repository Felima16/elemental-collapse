import SwiftUI
import RealityKit
import ARKit
import Combine

struct BoardARViewContainer: UIViewRepresentable {
    @Binding var viewModel: BoardViewModel

    // Necessary because makeUIView cannot edit instance variables
    var anchorObserver: CancellableWrapper = CancellableWrapper()
    var updateObserver: CancellableWrapper = CancellableWrapper()

    func makeUIView(context: Context) -> ARView {

        let arView = ARView.makeBoradARView(frame: .zero)
        updateObserver.cancel = arView.scene.subscribe(to: SceneEvents.Update.self, handleUpdateState(_:))
        anchorObserver.cancel = arView.scene.subscribe(to: SceneEvents.AnchoredStateChanged.self, handleAnchorState(_:))

        do {
            arView.scene.synchronizationService = try viewModel.gameNetwork.startSynchronizationService()
        } catch {
            print("Error startSynchronizationService for scene: \(error)")
        }

        Task {
            do {
                let board = try await viewModel.prepareBoard()
                let boardAnchor = AnchorEntity(.image(group: "AR Resources", name: "tree"), trackingMode: .predicted)
                boardAnchor.name = "boardAnchor"
                boardAnchor.addChild(board)
                arView.scene.addAnchor(boardAnchor)
            } catch {
                print("Error loading content: \(error)")
            }
        }

        return arView
    }

    func updateUIView(_ uiView: ARView, context: Context) {

    }
}

class CancellableWrapper {
    var cancel: Cancellable?
}

extension BoardARViewContainer {
    func handleAnchorState(_ anchorState: SceneEvents.AnchoredStateChanged) {
        viewModel.handleAnchorState(anchorState)
    }

    func handleUpdateState(_ updateEvent: SceneEvents.Update) {
        viewModel.handleUpdateState(updateEvent)
    }
}
