import Foundation
import CoreGraphics

struct CanvasConfig {
    static let containerMaxWidth: CGFloat = 600
    static let containerMaxHeight: CGFloat = 700
    static let artworkMaxWidth: CGFloat = 500
    static let artworkMaxHeight: CGFloat = 500
    static let artworkMinSize: CGFloat = 50
    static let artworkMaxResize: CGFloat = 800
    static let exportPixelRatioHigh: CGFloat = 3
    static let exportPixelRatioMedium: CGFloat = 2
    static let exportPixelRatioLow: CGFloat = 1
    static let exportQualityHigh: CGFloat = 1.0
    static let exportQualityMedium: CGFloat = 0.9
    static let exportQualityLow: CGFloat = 0.8
}

struct TShirtBounds {
    struct Front {
        static let minX: CGFloat = 103
        static let maxX: CGFloat = 493
        static let minY: CGFloat = 100
        static let maxY: CGFloat = 550
    }

    struct Back {
        static let minX: CGFloat = 140
        static let maxX: CGFloat = 510
        static let minY: CGFloat = 100
        static let maxY: CGFloat = 550
    }

    struct Neck {
        static let minX: CGFloat = 520
        static let maxX: CGFloat = 1080
        static let minY: CGFloat = 560
        static let maxY: CGFloat = 710
    }
}

struct HoodieBounds {
    struct Front {
        static let minX: CGFloat = 80
        static let maxX: CGFloat = 470
        static let minY: CGFloat = 100
        static let maxY: CGFloat = 650
    }

    struct Back {
        static let minX: CGFloat = 120
        static let maxX: CGFloat = 510
        static let minY: CGFloat = 100
        static let maxY: CGFloat = 650
    }
}
