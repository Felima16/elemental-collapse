import RealityKit
import ARKit

extension ARView {
    static func makeBoradARView(frame: CGRect) -> ARView {
        let arView = ARView(frame: frame)

        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal]
        config.environmentTexturing = .automatic
        config.isCollaborationEnabled = true

        // Enables humans and real objects to occlude virtual object
//        config.frameSemantics.insert(.personSegmentationWithDepth)
//        arView.environment.sceneUnderstanding.options.insert(.occlusion)

        //Reference images
        guard let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil) else {
            fatalError("Missing expected asset catalog resources.")
        }
        config.detectionImages = referenceImages

        arView.session.run(config, options: [.resetTracking, .removeExistingAnchors])

        return arView
    }
}
