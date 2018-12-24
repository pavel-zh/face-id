//
//  ViewController.swift
//  face-id
//
//  Created by Pavel Zhuravlev on 12/23/18.
//  Copyright © 2018 Pavel Zhuravlev. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet var faceSelectorButtons: [UIButton]!
    @IBOutlet weak var facesCollectionView: UICollectionView!

    private var allFotos = ["ab1", "ab2", "ab3", "ab4", "ab5", "ab6", "ab7", "ab8",
                            "barack1", "barack2", "barack3", "barack4", "barack5",
                            "jc1", "jc2", "jc3", "jc4",
                            "km1", "km2", "km3", "km4", "km5", "km6", "km7", "km8",
                            "vb1", "vb2", "vb3", "vb4", "vb5", "vb6"]
    var allFaces = [FaceIdService.Face]()
    private let faceSelectors = ["ab1", "barack3", "jc1", "km1", "vb1"]
    private var selectedFaceFeatures: FaceIdService.FaceFeatures?

    override func viewDidLoad() {
        zip(faceSelectorButtons, faceSelectors).forEach {
            $0.0.setImage(UIImage(named: $0.1), for: .normal)
            $0.0.layer.borderColor = UIColor.orange.cgColor
        }
        allFotos.shuffle()
        setupCollectionOfFaces()
        super.viewDidLoad()
    }

    @IBAction func faceSelected(_ selectedFaceButton: UIButton) {
        faceSelectorButtons.forEach { $0.layer.borderWidth = 0 }
        selectedFaceButton.layer.borderWidth = 10
        if let selectedFaceImage = UIImage(named: faceSelectors[selectedFaceButton.tag]) {
            selectSameFaces(as: selectedFaceImage)
        }
    }

    func setupCollectionOfFaces() {
        allFotos.forEach { imageName in
            if let image = UIImage(named: imageName) {
                FaceIdService.shared.identify(image: image) { faceFeatures in
                    guard let faceFeatures = faceFeatures else {
                        return
                    }
                    let newFace = FaceIdService.Face(photo: imageName, features: faceFeatures)
                    DispatchQueue.main.async {
                        self.allFaces.append(newFace)
                        self.facesCollectionView.reloadData()
                    }
                }
            }
        }
    }

    func selectSameFaces(as faceImage: UIImage) {
        facesCollectionView.visibleCells.forEach { cell in
            (cell as? PhotoCell)?.photoView.alpha = 1
        }

        FaceIdService.shared.identify(image: faceImage) { faceFeatures in
            DispatchQueue.main.async {
                self.selectedFaceFeatures = faceFeatures
                self.facesCollectionView.reloadData()
            }
        }
    }
}

// MARK: - UICollectionViewDataSource
extension ViewController {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allFaces.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let photoCell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCellId", for: indexPath) as? PhotoCell {
            photoCell.photoView.image = UIImage(named: allFaces[indexPath.row].photo)

            if let selectedFaceFeatures = selectedFaceFeatures {
                photoCell.photoView.alpha = FaceIdService.shared.isFace(allFaces[indexPath.row], hasCloseFeaturesWith: selectedFaceFeatures) ? 1 : 0.3
            }
            else {
                photoCell.photoView.alpha = 1
            }

            return photoCell
        }
        return UICollectionViewCell()
    }
}
