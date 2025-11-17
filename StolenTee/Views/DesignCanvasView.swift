import SwiftUI
import UIKit

// MARK: - Canvas Image Layer Model
struct CanvasImageLayer: Identifiable {
    let id: String
    var image: UIImage
    var position: CGPoint
    var scale: CGFloat
    var rotation: CGFloat
    var size: CGSize

    init(id: String = UUID().uuidString, image: UIImage, position: CGPoint = .zero, scale: CGFloat = 1.0, rotation: CGFloat = 0.0) {
        self.id = id
        self.image = image
        self.position = position
        self.scale = scale
        self.rotation = rotation

        // Calculate initial size to fit within max bounds
        let aspectRatio = image.size.width / image.size.height
        var width = CanvasConfig.artworkMaxWidth
        var height = width / aspectRatio

        if height > CanvasConfig.artworkMaxHeight {
            height = CanvasConfig.artworkMaxHeight
            width = height * aspectRatio
        }

        self.size = CGSize(width: width, height: height)
    }
}

// MARK: - UIKit Canvas View with Gesture Support
class CanvasUIView: UIView {
    var backgroundImage: UIImage?
    var layers: [CanvasImageLayer] = []
    var selectedLayerId: String?
    var bounds: CGRect = .zero

    var onLayerUpdate: ((CanvasImageLayer) -> Void)?
    var onLayerSelect: ((String?) -> Void)?

    private var activeLayer: CanvasImageLayer? {
        layers.first(where: { $0.id == selectedLayerId })
    }

    private var panGesture: UIPanGestureRecognizer!
    private var pinchGesture: UIPinchGestureRecognizer!
    private var rotationGesture: UIRotationGestureRecognizer!
    private var tapGesture: UITapGestureRecognizer!

    private var initialScale: CGFloat = 1.0
    private var initialRotation: CGFloat = 0.0

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGestures()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupGestures()
    }

    private func setupGestures() {
        // Pan gesture for dragging
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        addGestureRecognizer(panGesture)

        // Pinch gesture for scaling
        pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        addGestureRecognizer(pinchGesture)

        // Rotation gesture
        rotationGesture = UIRotationGestureRecognizer(target: self, action: #selector(handleRotation(_:)))
        addGestureRecognizer(rotationGesture)

        // Tap gesture for selection/deselection
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        addGestureRecognizer(tapGesture)

        // Allow simultaneous gestures
        panGesture.delegate = self
        pinchGesture.delegate = self
        rotationGesture.delegate = self
    }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard let selectedId = selectedLayerId,
              let index = layers.firstIndex(where: { $0.id == selectedId }) else {
            return
        }

        let translation = gesture.translation(in: self)

        switch gesture.state {
        case .changed:
            var layer = layers[index]
            let newPosition = CGPoint(
                x: layer.position.x + translation.x,
                y: layer.position.y + translation.y
            )

            // Constrain to bounds
            layer.position = constrainPosition(newPosition, for: layer)
            layers[index] = layer
            setNeedsDisplay()
            gesture.setTranslation(.zero, in: self)

        case .ended:
            onLayerUpdate?(layers[index])

        default:
            break
        }
    }

    @objc private func handlePinch(_ gesture: UIPinchGestureRecognizer) {
        guard let selectedId = selectedLayerId,
              let index = layers.firstIndex(where: { $0.id == selectedId }) else {
            return
        }

        switch gesture.state {
        case .began:
            initialScale = layers[index].scale

        case .changed:
            var layer = layers[index]
            let newScale = initialScale * gesture.scale

            // Constrain scale
            let minScale: CGFloat = CanvasConfig.artworkMinSize / max(layer.size.width, layer.size.height)
            let maxScale: CGFloat = CanvasConfig.artworkMaxResize / max(layer.size.width, layer.size.height)
            layer.scale = min(max(newScale, minScale), maxScale)

            layers[index] = layer
            setNeedsDisplay()

        case .ended:
            onLayerUpdate?(layers[index])

        default:
            break
        }
    }

    @objc private func handleRotation(_ gesture: UIRotationGestureRecognizer) {
        guard let selectedId = selectedLayerId,
              let index = layers.firstIndex(where: { $0.id == selectedId }) else {
            return
        }

        switch gesture.state {
        case .began:
            initialRotation = layers[index].rotation

        case .changed:
            var layer = layers[index]
            layer.rotation = initialRotation + gesture.rotation
            layers[index] = layer
            setNeedsDisplay()

        case .ended:
            onLayerUpdate?(layers[index])

        default:
            break
        }
    }

    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: self)

        // Check if tapped on any layer (in reverse order for top-to-bottom hit testing)
        for layer in layers.reversed() {
            if isPoint(location, inLayer: layer) {
                selectedLayerId = layer.id
                onLayerSelect?(layer.id)
                setNeedsDisplay()
                return
            }
        }

        // Tapped outside all layers - deselect
        selectedLayerId = nil
        onLayerSelect?(nil)
        setNeedsDisplay()
    }

    private func isPoint(_ point: CGPoint, inLayer layer: CanvasImageLayer) -> Bool {
        let scaledSize = CGSize(
            width: layer.size.width * layer.scale,
            height: layer.size.height * layer.scale
        )

        // Create a rect centered on the position
        let rect = CGRect(
            x: layer.position.x - scaledSize.width / 2,
            y: layer.position.y - scaledSize.height / 2,
            width: scaledSize.width,
            height: scaledSize.height
        )

        // For simplicity, check rect bounds (more complex hit testing with rotation could be added)
        return rect.contains(point)
    }

    private func constrainPosition(_ position: CGPoint, for layer: CanvasImageLayer) -> CGPoint {
        let scaledSize = CGSize(
            width: layer.size.width * layer.scale,
            height: layer.size.height * layer.scale
        )

        let halfWidth = scaledSize.width / 2
        let halfHeight = scaledSize.height / 2

        var constrainedX = position.x
        var constrainedY = position.y

        // Constrain to bounds
        if position.x - halfWidth < bounds.minX {
            constrainedX = bounds.minX + halfWidth
        }
        if position.x + halfWidth > bounds.maxX {
            constrainedX = bounds.maxX - halfWidth
        }
        if position.y - halfHeight < bounds.minY {
            constrainedY = bounds.minY + halfHeight
        }
        if position.y + halfHeight > bounds.maxY {
            constrainedY = bounds.maxY - halfHeight
        }

        return CGPoint(x: constrainedX, y: constrainedY)
    }

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }

        // Clear background
        context.clear(rect)

        // Draw background image (t-shirt mockup)
        if let bgImage = backgroundImage {
            bgImage.draw(in: bounds)
        }

        // Draw all layers
        for layer in layers {
            context.saveGState()

            // Move to position
            context.translateBy(x: layer.position.x, y: layer.position.y)

            // Apply rotation
            context.rotate(by: layer.rotation)

            // Apply scale
            context.scaleBy(x: layer.scale, y: layer.scale)

            // Draw image centered at origin
            let drawRect = CGRect(
                x: -layer.size.width / 2,
                y: -layer.size.height / 2,
                width: layer.size.width,
                height: layer.size.height
            )
            layer.image.draw(in: drawRect)

            context.restoreGState()

            // Draw selection indicator
            if layer.id == selectedLayerId {
                drawSelectionIndicator(for: layer, in: context)
            }
        }
    }

    private func drawSelectionIndicator(for layer: CanvasImageLayer, in context: CGContext) {
        context.saveGState()

        context.translateBy(x: layer.position.x, y: layer.position.y)
        context.rotate(by: layer.rotation)
        context.scaleBy(x: layer.scale, y: layer.scale)

        let selectionRect = CGRect(
            x: -layer.size.width / 2 - 5,
            y: -layer.size.height / 2 - 5,
            width: layer.size.width + 10,
            height: layer.size.height + 10
        )

        context.setStrokeColor(UIColor.black.cgColor)
        context.setLineWidth(2.0)
        context.stroke(selectionRect)

        // Draw corner handles
        let handleSize: CGFloat = 12
        let corners = [
            CGPoint(x: selectionRect.minX, y: selectionRect.minY),
            CGPoint(x: selectionRect.maxX, y: selectionRect.minY),
            CGPoint(x: selectionRect.minX, y: selectionRect.maxY),
            CGPoint(x: selectionRect.maxX, y: selectionRect.maxY)
        ]

        for corner in corners {
            let handleRect = CGRect(
                x: corner.x - handleSize / 2,
                y: corner.y - handleSize / 2,
                width: handleSize,
                height: handleSize
            )
            context.setFillColor(UIColor.white.cgColor)
            context.fillEllipse(in: handleRect)
            context.setStrokeColor(UIColor.black.cgColor)
            context.setLineWidth(2.0)
            context.strokeEllipse(in: handleRect)
        }

        context.restoreGState()
    }

    func captureImage(pixelRatio: CGFloat = 2.0) -> UIImage? {
        let format = UIGraphicsImageRendererFormat()
        format.scale = pixelRatio

        let renderer = UIGraphicsImageRenderer(bounds: bounds, format: format)
        return renderer.image { context in
            // Deselect before capture
            let wasSelected = selectedLayerId
            selectedLayerId = nil

            draw(bounds)

            // Restore selection
            selectedLayerId = wasSelected
        }
    }
}

// MARK: - UIGestureRecognizerDelegate
extension CanvasUIView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        // Allow pinch and rotation to work together
        return (gestureRecognizer == pinchGesture || gestureRecognizer == rotationGesture) &&
               (otherGestureRecognizer == pinchGesture || otherGestureRecognizer == rotationGesture)
    }
}

// MARK: - SwiftUI Wrapper
struct DesignCanvasView: UIViewRepresentable {
    let backgroundImage: UIImage?
    @Binding var layers: [CanvasImageLayer]
    @Binding var selectedLayerId: String?
    let bounds: CGRect
    let onLayerUpdate: ((CanvasImageLayer) -> Void)?

    func makeUIView(context: Context) -> CanvasUIView {
        let view = CanvasUIView()
        view.backgroundColor = .clear
        view.isMultipleTouchEnabled = true
        view.onLayerUpdate = onLayerUpdate
        view.onLayerSelect = { layerId in
            DispatchQueue.main.async {
                selectedLayerId = layerId
            }
        }
        return view
    }

    func updateUIView(_ uiView: CanvasUIView, context: Context) {
        uiView.backgroundImage = backgroundImage
        uiView.layers = layers
        uiView.selectedLayerId = selectedLayerId
        uiView.bounds = bounds
        uiView.setNeedsDisplay()
    }

    static func dismantleUIView(_ uiView: CanvasUIView, coordinator: ()) {
        uiView.onLayerUpdate = nil
        uiView.onLayerSelect = nil
    }
}
