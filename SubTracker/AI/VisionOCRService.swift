//
//  VisionOCRService.swift
//  SubTracker
//

import Foundation
import UIKit
import Vision

enum VisionOCRService {
    static func recognizeText(from image: UIImage) async throws -> String {
        let prepared = prepare(image)
        guard let cgImage = prepared.cgImage else {
            throw IntelligenceError.ocrFailed
        }

        return try await withCheckedThrowingContinuation { continuation in
            let request = VNRecognizeTextRequest { request, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                let observations = (request.results as? [VNRecognizedTextObservation] ?? [])
                    .sorted(by: Self.readOrder)

                var lines: [String] = []
                var currentLine: [String] = []
                var currentY: CGFloat?

                for observation in observations {
                    guard let candidate = observation.topCandidates(1).first else { continue }
                    let y = observation.boundingBox.midY
                    if let currentY, abs(currentY - y) > 0.018 {
                        let joined = currentLine.joined(separator: " ").trimmingCharacters(in: .whitespaces)
                        if !joined.isEmpty { lines.append(joined) }
                        currentLine = [candidate.string]
                    } else {
                        currentLine.append(candidate.string)
                    }
                    currentY = y
                }

                let last = currentLine.joined(separator: " ").trimmingCharacters(in: .whitespaces)
                if !last.isEmpty { lines.append(last) }

                let text = lines.joined(separator: "\n")
                if text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    continuation.resume(throwing: IntelligenceError.ocrFailed)
                } else {
                    continuation.resume(returning: text)
                }
            }

            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = true
            request.recognitionLanguages = ["en-US"]
            request.minimumTextHeight = 0.015
            if #available(iOS 16.0, *) {
                request.automaticallyDetectsLanguage = true
            }

            let orientation = CGImagePropertyOrientation(prepared.imageOrientation)
            let handler = VNImageRequestHandler(cgImage: cgImage, orientation: orientation, options: [:])
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: IntelligenceError.ocrFailed)
            }
        }
    }

    nonisolated private static func readOrder(_ lhs: VNRecognizedTextObservation, _ rhs: VNRecognizedTextObservation) -> Bool {
        if abs(lhs.boundingBox.midY - rhs.boundingBox.midY) > 0.018 {
            return lhs.boundingBox.midY > rhs.boundingBox.midY
        }
        return lhs.boundingBox.minX < rhs.boundingBox.minX
    }

    /// Normalize orientation and upscale small screenshots so OCR has more pixels to work with.
    private static func prepare(_ image: UIImage) -> UIImage {
        let longest = max(image.size.width, image.size.height)
        let scale = longest < 1200 ? 1200 / longest : 1
        let size = CGSize(width: image.size.width * scale, height: image.size.height * scale)
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = 1
        format.opaque = true
        return UIGraphicsImageRenderer(size: size, format: format).image { _ in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
    }
}

private extension CGImagePropertyOrientation {
    init(_ orientation: UIImage.Orientation) {
        switch orientation {
        case .up: self = .up
        case .down: self = .down
        case .left: self = .left
        case .right: self = .right
        case .upMirrored: self = .upMirrored
        case .downMirrored: self = .downMirrored
        case .leftMirrored: self = .leftMirrored
        case .rightMirrored: self = .rightMirrored
        @unknown default: self = .up
        }
    }
}
