import UIKit
import Vision

class OCRService {

    static func recognizeText(
        from image: UIImage,
        completion: @escaping (String) -> Void
    ) {

        guard let cgImage = image.cgImage else { return }

        let request = VNRecognizeTextRequest { request, error in

            guard let results = request.results
                    as? [VNRecognizedTextObservation] else {
                return
            }

            let text = results.compactMap {

                $0.topCandidates(1).first?.string

            }.joined(separator: "\n")

            DispatchQueue.main.async {

                completion(text)
            }
        }

        request.recognitionLevel = .accurate

        let handler = VNImageRequestHandler(cgImage: cgImage)

        try? handler.perform([request])
    }
}
