//
//  FaceIdService.swift
//  face-id
//
//  Created by Pavel Zhuravlev on 12/23/18.
//  Copyright © 2018 Pavel Zhuravlev. All rights reserved.
//

import UIKit
import CoreML
import Vision

class FaceIdService {

    typealias FaceFeatures = MLMultiArray

    struct Face {
        let photo: String
        var features: FaceIdService.FaceFeatures
    }

    static var shared = FaceIdService()

    private init() {
    }

    func identify(image: UIImage, withCompletion completion: @escaping (_ faceFeatures: FaceFeatures?) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            guard let cgImage = image.cgImage else {
                completion(nil)
                return
            }
            guard let faceIdmodel = try? VNCoreMLModel(for: FaceId_resnet50_quantized(configuration: MLModelConfiguration()).model) else {
                completion(nil)
                return
            }

            let handler = VNImageRequestHandler(ciImage: CIImage(cgImage: cgImage))
            let faceIdRequest = VNCoreMLRequest(model: faceIdmodel) { request, error in
                guard let observations = request.results as? [VNCoreMLFeatureValueObservation],
                    let faceFeatures = observations.first?.featureValue.multiArrayValue else {
                        completion(nil)
                        return
                }
                completion(faceFeatures)
            }

            do {
                try handler.perform([faceIdRequest])
            }
            catch {
                completion(nil)
            }
        }
    }

    func isFace(_ face: Face, hasCloseFeaturesWith otherFaceFeatures: MLMultiArray) -> Bool {
        let treshold = 102.0 // find what is best
        var distance: Double = 0

        for index in 0..<otherFaceFeatures.count {
            let delta = face.features[index].doubleValue - otherFaceFeatures[index].doubleValue
            distance += delta * delta
        }
        distance = distance.squareRoot()

        return distance < treshold
    }
}
