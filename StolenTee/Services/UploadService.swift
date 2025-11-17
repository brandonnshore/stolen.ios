import Foundation
import UIKit

class UploadService {
    static let shared = UploadService()
    private init() {}

    // MARK: - Upload File
    func uploadFile(image: UIImage, fileName: String = "upload.jpg") async throws -> Asset {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw APIError.serverError("Failed to convert image to data")
        }

        let response: UploadResponse = try await APIClient.shared.upload(
            endpoint: Configuration.Endpoint.uploadFile,
            image: imageData,
            fileName: fileName,
            requiresAuth: true
        )

        return response.asset
    }

    // MARK: - Upload Shirt Photo for Extraction
    func uploadShirtPhoto(image: UIImage) async throws -> (asset: Asset, jobId: String) {
        guard let imageData = image.jpegData(compressionQuality: 0.9) else {
            throw APIError.serverError("Failed to convert image to data")
        }

        let response: ShirtPhotoUploadResponse = try await APIClient.shared.upload(
            endpoint: Configuration.Endpoint.uploadShirtPhoto,
            image: imageData,
            fileName: "shirt_photo.jpg",
            requiresAuth: false
        )

        return (response.asset, response.jobId)
    }

    // MARK: - Get Job Status
    func getJobStatus(jobId: String) async throws -> (job: Job, assets: [Asset]?) {
        let response: JobResponse = try await APIClient.shared.request(
            endpoint: Configuration.Endpoint.jobStatus(jobId)
        )
        return (response.job, response.assets)
    }

    // MARK: - Poll Job Until Complete
    func pollJobUntilComplete(jobId: String, maxAttempts: Int = 60) async throws -> (job: Job, assets: [Asset]?) {
        for _ in 0..<maxAttempts {
            let (job, assets) = try await getJobStatus(jobId: jobId)

            switch job.status {
            case "done":
                return (job, assets)
            case "error":
                throw APIError.serverError(job.errorMessage ?? "Job failed")
            default:
                // Still processing, wait and try again
                try await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
            }
        }

        throw APIError.serverError("Job timed out after \(maxAttempts) attempts")
    }
}
