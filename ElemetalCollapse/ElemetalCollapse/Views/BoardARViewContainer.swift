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
        updateObserver.cancel = viewModel.arView.scene.subscribe(to: SceneEvents.Update.self, handleUpdateState(_:))
        anchorObserver.cancel = viewModel.arView.scene.subscribe(to: SceneEvents.AnchoredStateChanged.self, handleAnchorState(_:))
        viewModel.arView.session.delegate = viewModel

        do {
            viewModel.arView.scene.synchronizationService = try viewModel.gameNetwork.startSynchronizationService()
        } catch {
            print("Error startSynchronizationService for scene: \(error)")
        }

        Task {
            do {
                let board = try await viewModel.prepareBoard()
                let boardAnchor = AnchorEntity(.plane(.horizontal, classification: .table, minimumBounds: SIMD2<Float>(0.2, 0.2)))
                boardAnchor.name = "boardAnchor"
                boardAnchor.addChild(board)
                viewModel.arView.scene.addAnchor(boardAnchor)
                viewModel.board = boardAnchor

            } catch {
                print("Error loading content: \(error)")
            }
        }

        let arViewTap = UITapGestureRecognizer(target: viewModel, action: #selector(viewModel.selected(recognizer:)))
        viewModel.arView.addGestureRecognizer(arViewTap)

        return viewModel.arView
    }

    func updateUIView(_ uiView: ARView, context: Context) { }
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
