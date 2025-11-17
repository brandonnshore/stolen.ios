import SwiftUI
import PhotosUI

struct CustomizerView: View {
    let product: Product
    let variants: [Variant]

    @StateObject private var viewModel = CustomizerViewModel()
    @State private var selectedColor: String = ""
    @State private var selectedSize: String = ""
    @State private var quantity: Int = 1

    // Canvas state
    @State private var canvasLayers: [CanvasImageLayer] = []
    @State private var selectedLayerId: String?
    @State private var backgroundImage: UIImage?
    @State private var canvasBounds: CGRect = .zero

    // Photo picker
    @State private var showingPhotoPicker = false
    @State private var selectedPhoto: PhotosPickerItem?

    // Alert and toast
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var showToast = false
    @State private var toastMessage = ""

    private let tshirtColors = ["White", "Black", "Navy"]
    private let sizes = ["XS", "S", "M", "L", "XL", "2XL", "3XL"]

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.white.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Header
                    CustomizerHeader(
                        productTitle: product.title,
                        onSave: handleSaveDesign,
                        onDownload: handleDownloadDesign
                    )

                    HStack(spacing: 0) {
                        // Left sidebar - Upload & Controls
                        ScrollView {
                            VStack(alignment: .leading, spacing: 20) {
                                uploadSection
                                extractionStatusSection
                                colorSelectionSection
                                sizeSelectionSection
                                quantitySection
                                pricingSection
                                addToCartButton
                            }
                            .padding()
                        }
                        .frame(width: geometry.size.width * 0.3)
                        .background(Color(UIColor.systemGray6))

                        Divider()

                        // Right side - Canvas
                        canvasArea
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }

                // Toast overlay
                if showToast {
                    VStack {
                        Spacer()
                        ToastView(message: toastMessage)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                            .padding()
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            setupInitialState()
        }
        .onChange(of: selectedPhoto) { newItem in
            loadPhoto(newItem)
        }
        .onChange(of: viewModel.extractedAssets) { assets in
            handleExtractedAssets(assets)
        }
        .onChange(of: viewModel.currentView) { _ in
            updateCanvasForView()
        }
        .onChange(of: selectedColor) { _ in
            updateBackgroundImage()
        }
        .alert("Error", isPresented: $showingAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
    }

    // MARK: - Upload Section
    private var uploadSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Upload Shirt Photo")
                .font(.headline)

            Text("Upload a photo of your shirt and we'll extract the design automatically")
                .font(.caption)
                .foregroundColor(.secondary)

            // AI Disclaimer
            HStack(spacing: 8) {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(.blue)
                Text("This is done using AI, and sometimes it requires multiple tries to get your perfect, desired result.")
                    .font(.caption2)
                    .foregroundColor(.blue)
            }
            .padding(10)
            .background(Color.blue.opacity(0.1))
            .cornerRadius(8)

            // Upload button
            PhotosPicker(selection: $selectedPhoto, matching: .images) {
                VStack(spacing: 12) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 36))
                        .foregroundColor(.gray)

                    Text("Click to upload")
                        .font(.subheadline)
                        .fontWeight(.medium)

                    Text("JPG or PNG up to 25MB")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
                .background(Color.white)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [5]))
                        .foregroundColor(.gray.opacity(0.5))
                )
            }
            .disabled(viewModel.isExtracting)
        }
    }

    // MARK: - Extraction Status Section
    @ViewBuilder
    private var extractionStatusSection: some View {
        if viewModel.isExtracting {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Stealing your t-shirt")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Spacer()
                    ProgressView()
                        .scaleEffect(0.8)
                }

                ProgressView(value: viewModel.extractionPercent)
                    .progressViewStyle(.linear)
                    .tint(.blue)

                Text(viewModel.extractionProgress)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color.blue.opacity(0.1))
            .cornerRadius(12)
        } else if !viewModel.extractedAssets.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text("Extraction Complete!")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.green)

                Text("Logo extracted successfully! You can now position it on the shirt.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color.green.opacity(0.1))
            .cornerRadius(12)
        } else if let error = viewModel.errorMessage {
            VStack(alignment: .leading, spacing: 12) {
                Text("Error")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.red)

                Text(error)
                    .font(.caption)
                    .foregroundColor(.secondary)

                Button("Try Again") {
                    viewModel.errorMessage = nil
                }
                .font(.caption)
                .foregroundColor(.red)
            }
            .padding()
            .background(Color.red.opacity(0.1))
            .cornerRadius(12)
        }
    }

    // MARK: - Color Selection
    private var colorSelectionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Garment Color")
                .font(.subheadline)
                .fontWeight(.semibold)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(tshirtColors, id: \.self) { color in
                    Button {
                        selectedColor = color
                    } label: {
                        HStack(spacing: 8) {
                            Circle()
                                .fill(colorForName(color))
                                .frame(width: 30, height: 30)
                                .overlay(
                                    Circle()
                                        .strokeBorder(Color.gray.opacity(0.3), lineWidth: 1)
                                )

                            Text(color)
                                .font(.subheadline)
                                .foregroundColor(.primary)

                            Spacer()
                        }
                        .padding(12)
                        .background(selectedColor == color ? Color.black.opacity(0.05) : Color.white)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .strokeBorder(selectedColor == color ? Color.black : Color.gray.opacity(0.3), lineWidth: selectedColor == color ? 2 : 1)
                        )
                    }
                }
            }
        }
    }

    // MARK: - Size Selection
    private var sizeSelectionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Size")
                .font(.subheadline)
                .fontWeight(.semibold)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                ForEach(sizes, id: \.self) { size in
                    Button {
                        selectedSize = size
                    } label: {
                        Text(size)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(selectedSize == size ? .white : .primary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(selectedSize == size ? Color.black : Color.white)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .strokeBorder(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                    }
                }
            }
        }
    }

    // MARK: - Quantity Section
    private var quantitySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quantity")
                .font(.subheadline)
                .fontWeight(.semibold)

            HStack {
                Button {
                    if quantity > 1 {
                        quantity -= 1
                    }
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .font(.title2)
                        .foregroundColor(quantity > 1 ? .black : .gray)
                }
                .disabled(quantity <= 1)

                Spacer()

                Text("\(quantity)")
                    .font(.title3)
                    .fontWeight(.semibold)

                Spacer()

                Button {
                    quantity += 1
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(.black)
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(8)
        }
    }

    // MARK: - Pricing Section
    private var pricingSection: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Unit Price")
                    .foregroundColor(.secondary)
                Spacer()
                Text("$\(String(format: "%.2f", unitPrice))")
                    .fontWeight(.semibold)
            }

            if quantity > 1 {
                Divider()
                HStack {
                    Text("Total")
                        .fontWeight(.bold)
                    Spacer()
                    Text("$\(String(format: "%.2f", totalPrice))")
                        .font(.title3)
                        .fontWeight(.bold)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(8)
    }

    // MARK: - Add to Cart Button
    private var addToCartButton: some View {
        Button {
            handleAddToCart()
        } label: {
            Text("Add to Cart")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(canAddToCart ? Color.black : Color.gray)
                .cornerRadius(25)
        }
        .disabled(!canAddToCart)
    }

    // MARK: - Canvas Area
    private var canvasArea: some View {
        ZStack {
            Color.white

            VStack {
                // Canvas with gestures
                if let bgImage = backgroundImage {
                    DesignCanvasView(
                        backgroundImage: bgImage,
                        layers: $canvasLayers,
                        selectedLayerId: $selectedLayerId,
                        bounds: canvasBounds,
                        onLayerUpdate: { layer in
                            updateLayerInViewModel(layer)
                        }
                    )
                    .frame(width: canvasBounds.width, height: canvasBounds.height)
                } else {
                    ProgressView("Loading canvas...")
                }

                Spacer()

                // View switcher
                HStack(spacing: 8) {
                    ForEach([CanvasView.front, CanvasView.back], id: \.self) { view in
                        Button {
                            viewModel.currentView = view
                        } label: {
                            Text(view.displayName)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(viewModel.currentView == view ? .white : .primary)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(viewModel.currentView == view ? Color.black : Color.clear)
                                .cornerRadius(20)
                        }
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(25)
                .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
                .padding(.bottom, 20)
            }

            // Instructions overlay
            if !canvasLayers.isEmpty {
                VStack {
                    if selectedLayerId != nil {
                        Text("Drag to move • Pinch to resize • Rotate with two fingers • Tap away to finish")
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.black.opacity(0.8))
                            .cornerRadius(20)
                    } else {
                        Text("Tap artwork to edit position and size")
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.gray.opacity(0.6))
                            .cornerRadius(20)
                    }

                    Spacer()
                }
                .padding(.top, 12)
            }
        }
    }

    // MARK: - Helper Methods
    private func setupInitialState() {
        selectedColor = tshirtColors.first ?? "White"
        selectedSize = "M"
        updateBackgroundImage()
    }

    private func updateBackgroundImage() {
        let imageName: String
        switch selectedColor.lowercased() {
        case "black":
            imageName = viewModel.currentView == .back ? "black-back" : "black-front"
        case "navy":
            imageName = viewModel.currentView == .back ? "navy-back" : "navy-front"
        default:
            imageName = viewModel.currentView == .back ? "back-tshirt" : "blank-tshirt"
        }

        if let image = UIImage(named: imageName) {
            backgroundImage = image

            // Calculate canvas bounds based on image
            let aspectRatio = image.size.width / image.size.height
            var width = CanvasConfig.containerMaxWidth
            var height = width / aspectRatio

            if height > CanvasConfig.containerMaxHeight {
                height = CanvasConfig.containerMaxHeight
                width = height * aspectRatio
            }

            canvasBounds = CGRect(x: 0, y: 0, width: width, height: height)
        }
    }

    private func updateCanvasForView() {
        updateBackgroundImage()
        // Sync layers from view model
        syncLayersFromViewModel()
    }

    private func syncLayersFromViewModel() {
        // Convert CanvasObject to CanvasImageLayer
        canvasLayers = []

        for canvasObj in viewModel.canvasObjects {
            guard canvasObj.type == "image",
                  let urlString = canvasObj.imageUrl,
                  let url = URL(string: urlString) else {
                continue
            }

            // Load image asynchronously
            Task {
                if let (data, _) = try? await URLSession.shared.data(from: url),
                   let image = UIImage(data: data) {
                    let layer = CanvasImageLayer(
                        id: canvasObj.id,
                        image: image,
                        position: CGPoint(x: canvasObj.x, y: canvasObj.y),
                        scale: canvasObj.scaleX,
                        rotation: canvasObj.rotation
                    )

                    await MainActor.run {
                        canvasLayers.append(layer)
                    }
                }
            }
        }
    }

    private func loadPhoto(_ item: PhotosPickerItem?) {
        guard let item = item else { return }

        Task {
            if let data = try? await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                await viewModel.uploadShirtPhoto(image)
            }
        }
    }

    private func handleExtractedAssets(_ assets: [Asset]) {
        guard let transparentAsset = assets.first(where: { asset in
            asset.metadata?["type"]?.value as? String == "transparent"
        }) else {
            return
        }

        // Add extracted asset to canvas
        viewModel.addAssetToCanvas(transparentAsset)

        // Load the image and create a canvas layer
        if let url = URL(string: transparentAsset.fileUrl) {
            Task {
                if let (data, _) = try? await URLSession.shared.data(from: url),
                   let image = UIImage(data: data) {
                    let centerX = canvasBounds.width / 2
                    let centerY = canvasBounds.height / 2

                    let layer = CanvasImageLayer(
                        id: UUID().uuidString,
                        image: image,
                        position: CGPoint(x: centerX, y: centerY),
                        scale: 1.0,
                        rotation: 0
                    )

                    await MainActor.run {
                        canvasLayers.append(layer)
                        selectedLayerId = layer.id
                    }
                }
            }
        }
    }

    private func updateLayerInViewModel(_ layer: CanvasImageLayer) {
        // Update the corresponding CanvasObject in the view model
        if let index = viewModel.canvasObjects.firstIndex(where: { $0.id == layer.id }) {
            viewModel.updateObjectPosition(
                viewModel.canvasObjects[index],
                x: layer.position.x,
                y: layer.position.y
            )
            viewModel.updateObjectRotation(
                viewModel.canvasObjects[index],
                rotation: layer.rotation
            )
        }
    }

    private func handleSaveDesign() {
        // TODO: Implement save design functionality
        showToastMessage("Design saved successfully!")
    }

    private func handleDownloadDesign() {
        // TODO: Implement download functionality
        showToastMessage("Design downloaded!")
    }

    private func handleAddToCart() {
        guard !selectedColor.isEmpty && !selectedSize.isEmpty else {
            alertMessage = "Please select a color and size"
            showingAlert = true
            return
        }

        // TODO: Implement add to cart functionality
        showToastMessage("Added to cart successfully!")
    }

    private func showToastMessage(_ message: String) {
        toastMessage = message
        withAnimation {
            showToast = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            withAnimation {
                showToast = false
            }
        }
    }

    private func colorForName(_ name: String) -> Color {
        switch name.lowercased() {
        case "white": return .white
        case "black": return .black
        case "navy": return Color(red: 0, green: 0.12, blue: 0.25)
        default: return .gray
        }
    }


    private var unitPrice: Double {
        let basePrice = 12.98
        let hasFrontArt = !canvasLayers.isEmpty && viewModel.currentView == .front
        let hasBackArt = !canvasLayers.isEmpty && viewModel.currentView == .back

        var price = basePrice
        if hasFrontArt { price += 3.00 }
        if hasBackArt { price += 3.00 }

        return price
    }

    private var totalPrice: Double {
        unitPrice * Double(quantity)
    }

    private var canAddToCart: Bool {
        !selectedColor.isEmpty && !selectedSize.isEmpty
    }
}

// MARK: - Supporting Views
struct CustomizerHeader: View {
    let productTitle: String
    let onSave: () -> Void
    let onDownload: () -> Void

    var body: some View {
        HStack {
            Text(productTitle)
                .font(.headline)

            Spacer()

            HStack(spacing: 12) {
                Button(action: onDownload) {
                    Image(systemName: "arrow.down.circle")
                        .font(.title3)
                }

                Button(action: onSave) {
                    HStack {
                        Image(systemName: "square.and.arrow.down")
                        Text("Save")
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.black)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(Color.white)
        .shadow(color: .black.opacity(0.05), radius: 2, y: 1)
    }
}

struct ToastView: View {
    let message: String

    var body: some View {
        Text(message)
            .font(.subheadline)
            .foregroundColor(.white)
            .padding()
            .background(Color.black.opacity(0.8))
            .cornerRadius(10)
    }
}
