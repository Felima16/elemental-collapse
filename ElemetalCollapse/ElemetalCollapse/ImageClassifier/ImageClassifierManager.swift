import CoreML
import Vision
import SwiftUI

enum RecognitionError: Error {
    case unableToInitializeCoreMLModel
    case resultIsEmpty
    case lowConfidence
}

protocol ImageClassifierManagerDelegate: AnyObject {
    func pirceSelect(elementalPierceSelect: ElementalPiece) async
}

@MainActor @Observable
final class ImageClassifierManager {
    @ObservationIgnored
    private let imageClassifier: ElemetalClassifier = {
        do {
            return try ElemetalClassifier(configuration: MLModelConfiguration())
        } catch {
            fatalError(error.localizedDescription)
        }
    }()

    var visionRequests = [VNRequest]()
    weak var delegate: ImageClassifierManagerDelegate?

    func visionRequest( _ buffer : CVPixelBuffer) async {
        do {
            let visionModel = try VNCoreMLModel(for: imageClassifier.model)
            let request = VNCoreMLRequest(model: visionModel) {
                request,
                error in
                
                guard error == nil,
                      let observations = request.results ,
                      let observation = observations.first as? VNClassificationObservation else {
                    return
                }
                
                print("##### Object Name: \(observation.identifier) , \(observation.confidence * 100)")
                
                Task {
                    await self.delegate?.pirceSelect(
                        elementalPierceSelect: ElementalPiece(rawValue: observation.identifier) ?? .none
                    )
                }

            }
            request.imageCropAndScaleOption = .centerCrop
            visionRequests = [request]
            let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: buffer,
                                                            orientation: .upMirrored,
                                                            options: [:])

            try imageRequestHandler.perform(visionRequests)
        } catch {

        }
    }
}

public enum ElementalPiece: String {
    case fire = "fire"
    case air = "air"
    case water = "water"
    case earth = "earth"
    case none = "none"
}
