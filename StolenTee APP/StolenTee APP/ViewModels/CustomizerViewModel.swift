import Foundation
import SwiftUI
import UIKit
import Combine

enum CanvasView: String, CaseIterable {
    case front = "front_chest"
    case back = "back_center"
    case neck = "neck_label"

    var displayName: String {
        switch self {
        case .front: return "Front"
        case .back: return "Back"
        case .neck: return "Neck"
        }
    }
}

@MainActor
class CustomizerViewModel: ObservableObject {
    @Published var currentView: CanvasView = .front
    @Published var extractedAssets: [Asset] = []
    @Published var selectedAsset: Asset?
    @Published var canvasObjects: [CanvasObject] = []
    @Published var isExtracting = false
    @Published var extractionProgress: String = ""
    @Published var extractionPercent: Double = 0.0
    @Published var errorMessage: String?

    private var pollingTask: Task<Void, Never>?

    // MARK: - Upload Shirt Photo for Extraction
    func uploadShirtPhoto(_ image: UIImage) async {
        isExtracting = true
        extractionProgress = "Uploading photo..."
        extractionPercent = 0.05
        errorMessage = nil

        do {
            let (_, jobId) = try await UploadService.shared.uploadShirtPhoto(image: image)

            guard let jobId = jobId else {
                throw NSError(domain: "CustomizerViewModel", code: 1,
                            userInfo: [NSLocalizedDescriptionKey: "No job ID returned. Background processing may be disabled."])
            }

            extractionProgress = "Starting extraction process..."
            extractionPercent = 0.15

            // Start polling with progress updates
            pollingTask = Task {
                await pollJobWithProgress(jobId: jobId)
            }

            await pollingTask?.value
        } catch {
            errorMessage = error.localizedDescription
            extractionProgress = ""
            extractionPercent = 0.0
        }

        isExtracting = false
    }

    private func pollJobWithProgress(jobId: String) async {
        var targetPercent = 0.15

        for attempt in 0..<60 {
            do {
                let (job, assets) = try await UploadService.shared.getJobStatus(jobId: jobId)

                // Calculate progress based on job logs
                if job.status == "running", let logs = job.logs?.lowercased() {
                    if logs.contains("step 1") || logs.contains("gemini") {
                        targetPercent = 0.35
                        extractionProgress = "AI analyzing image..."
                    } else if logs.contains("step 2") || logs.contains("background") {
                        targetPercent = 0.60
                        extractionProgress = "Removing background..."
                    } else if logs.contains("step 3") || logs.contains("dpi") {
                        targetPercent = 0.80
                        extractionProgress = "Enhancing quality..."
                    } else if logs.contains("step 4") || logs.contains("verifying") {
                        targetPercent = 0.95
                        extractionProgress = "Finalizing..."
                    }
                }

                // Smooth progress animation
                while extractionPercent < targetPercent {
                    extractionPercent += 0.02
                    try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
                }

                if job.status == "done" {
                    extractionPercent = 1.0
                    extractionProgress = "Complete!"

                    if let resultAssets = assets {
                        extractedAssets = resultAssets

                        // Auto-select transparent version (View will handle canvas positioning)
                        if let transparentAsset = resultAssets.first(where: { $0.kind == "transparent" }) {
                            selectedAsset = transparentAsset
                        } else if let firstAsset = resultAssets.first {
                            selectedAsset = firstAsset
                        }
                    }

                    return
                } else if job.status == "error" {
                    errorMessage = job.errorMessage ?? "Extraction failed"
                    extractionProgress = ""
                    extractionPercent = 0.0
                    return
                }

                // Wait before next poll
                try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
            } catch {
                errorMessage = error.localizedDescription
                extractionProgress = ""
                extractionPercent = 0.0
                return
            }
        }

        errorMessage = "Job timed out after 60 attempts"
        extractionProgress = ""
        extractionPercent = 0.0
    }

    func cancelExtraction() {
        pollingTask?.cancel()
        pollingTask = nil
        isExtracting = false
        extractionProgress = ""
        extractionPercent = 0.0
    }

    // MARK: - Add Asset to Canvas
    func addAssetToCanvas(_ asset: Asset) {
        let canvasObject = CanvasObject(
            id: UUID().uuidString,
            type: "image",
            x: 100,
            y: 100,
            width: 200,
            height: 200,
            rotation: 0,
            scaleX: 1.0,
            scaleY: 1.0,
            imageUrl: asset.fileUrl,
            text: nil,
            fontFamily: nil,
            fontSize: nil,
            fill: nil,
            stroke: nil
        )

        canvasObjects.append(canvasObject)
    }

    // MARK: - Remove Object from Canvas
    func removeObject(_ object: CanvasObject) {
        canvasObjects.removeAll { $0.id == object.id }
    }

    // MARK: - Update Object Position
    func updateObjectPosition(_ object: CanvasObject, x: Double, y: Double) {
        if let index = canvasObjects.firstIndex(where: { $0.id == object.id }) {
            canvasObjects[index] = CanvasObject(
                id: object.id,
                type: object.type,
                x: x,
                y: y,
                width: object.width,
                height: object.height,
                rotation: object.rotation,
                scaleX: object.scaleX,
                scaleY: object.scaleY,
                imageUrl: object.imageUrl,
                text: object.text,
                fontFamily: object.fontFamily,
                fontSize: object.fontSize,
                fill: object.fill,
                stroke: object.stroke
            )
        }
    }

    // MARK: - Update Object Size
    func updateObjectSize(_ object: CanvasObject, width: Double, height: Double) {
        if let index = canvasObjects.firstIndex(where: { $0.id == object.id }) {
            canvasObjects[index] = CanvasObject(
                id: object.id,
                type: object.type,
                x: object.x,
                y: object.y,
                width: width,
                height: height,
                rotation: object.rotation,
                scaleX: object.scaleX,
                scaleY: object.scaleY,
                imageUrl: object.imageUrl,
                text: object.text,
                fontFamily: object.fontFamily,
                fontSize: object.fontSize,
                fill: object.fill,
                stroke: object.stroke
            )
        }
    }

    // MARK: - Update Object Rotation
    func updateObjectRotation(_ object: CanvasObject, rotation: Double) {
        if let index = canvasObjects.firstIndex(where: { $0.id == object.id }) {
            canvasObjects[index] = CanvasObject(
                id: object.id,
                type: object.type,
                x: object.x,
                y: object.y,
                width: object.width,
                height: object.height,
                rotation: rotation,
                scaleX: object.scaleX,
                scaleY: object.scaleY,
                imageUrl: object.imageUrl,
                text: object.text,
                fontFamily: object.fontFamily,
                fontSize: object.fontSize,
                fill: object.fill,
                stroke: object.stroke
            )
        }
    }

    // MARK: - Get Design Data for Saving
    func getDesignData() -> DesignData {
        return DesignData(
            canvasObjects: canvasObjects,
            backgroundColor: nil,
            selectedView: currentView.rawValue
        )
    }

    // MARK: - Load Design Data
    func loadDesignData(_ designData: DesignData) {
        canvasObjects = designData.canvasObjects
        if let viewRaw = designData.selectedView,
           let view = CanvasView(rawValue: viewRaw) {
            currentView = view
        }
    }
}
