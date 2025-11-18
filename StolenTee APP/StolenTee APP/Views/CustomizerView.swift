import SwiftUI
import PhotosUI

// MARK: - MOBILE-FIRST CUSTOMIZER VIEW
// Completely rebuilt for mobile with vertical scrolling layout
// Order: Canvas -> Upload -> Color -> Size -> Quantity/Price -> Actions

struct CustomizerView: View {
    let product: Product
    let variants: [ProductVariant]

    @StateObject private var viewModel = CustomizerViewModel()
    @EnvironmentObject var cartViewModel: CartViewModel
    @State private var selectedColor: String = ""
    @State private var selectedSize: String = ""
    @State private var quantity: Int = 1

    // Canvas state
    @State private var canvasLayers: [CanvasImageLayer] = []
    @State private var selectedLayerId: String?
    @State private var backgroundImage: UIImage?
    @State private var canvasBounds: CGRect = .zero

    // Photo picker
    @State private var selectedPhoto: PhotosPickerItem?

    // Alert and toast
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var showToast = false
    @State private var toastMessage = ""
    @State private var toastType: ToastView.ToastType = .info

    private let tshirtColors = ["White", "Black", "Navy"]
    private let sizes = ["XS", "S", "M", "L", "XL", "2XL", "3XL"]

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            // MOBILE-FIRST VERTICAL SCROLLING LAYOUT
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // 1. CANVAS - Top & Most Prominent (Large touch-friendly area)
                    canvasSection
                        .padding(.bottom, 24)

                    // 2. UPLOAD SECTION - Direct below canvas
                    uploadSectionMobile
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)

                    // Extraction status (conditional)
                    extractionStatusSection
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)

                    // 3. COLOR SELECTOR - Horizontal scrollable swatches
                    colorSelectorMobile
                        .padding(.bottom, 20)

                    // 4. SIZE SELECTOR - Grid layout
                    sizeSelectorMobile
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)

                    // 5. QUANTITY & PRICE - Combined card
                    quantityAndPriceSection
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)

                    // 6. ACTION BUTTONS - Bottom CTA
                    actionButtonsSection
                        .padding(.horizontal, 20)
                        .padding(.bottom, 40)
                }
            }

            // Toast overlay
            if showToast {
                VStack {
                    Spacer()
                    ToastView(message: toastMessage, type: toastType)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .padding()
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(product.title)
                    .font(.headline)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: handleSaveDesign) {
                        Label("Save Design", systemImage: "heart")
                    }
                    Button(action: handleDownloadDesign) {
                        Label("Download", systemImage: "arrow.down.circle")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.body)
                }
            }
        }
        .onAppear {
            setupInitialState()
        }
        .onChange(of: selectedPhoto) { newItem in
            loadPhoto(newItem)
        }
        .onChange(of: viewModel.extractedAssets.map { $0.id }) { _ in
            handleExtractedAssets(viewModel.extractedAssets)
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

    // MARK: - 1. Canvas Section (Edge-to-Edge, iOS Glass Morphism)
    private var canvasSection: some View {
        GeometryReader { geometry in
            ZStack {
                // Edge-to-edge background
                Color(UIColor.systemGray6).ignoresSafeArea()

                VStack(spacing: 0) {
                    if let bgImage = backgroundImage {
                        // Canvas with product mockup - fills screen width
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
                        .clipped()
                    } else {
                        ProgressView("Loading canvas...")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                // Floating instructions at top (if editing)
                if !canvasLayers.isEmpty && selectedLayerId != nil {
                    VStack {
                        Text("Drag • Pinch • Rotate • Tap away to finish")
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(.ultraThinMaterial)
                            .background(Color.black.opacity(0.3))
                            .cornerRadius(20)
                            .padding(.top, 16)
                        Spacer()
                    }
                }

                // iOS Glass Morphism View Selector at bottom
                VStack {
                    Spacer()

                    HStack(spacing: 0) {
                        ForEach([CanvasView.front, CanvasView.back, CanvasView.neck], id: \.self) { view in
                            Button {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    viewModel.currentView = view
                                }
                            } label: {
                                Text(view.displayName.uppercased())
                                    .font(.system(size: 12, weight: viewModel.currentView == view ? .semibold : .medium))
                                    .foregroundColor(viewModel.currentView == view ? .primary : .secondary)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(
                                        ZStack {
                                            if viewModel.currentView == view {
                                                // Active tab with subtle background
                                                RoundedRectangle(cornerRadius: 10)
                                                    .fill(Color.white.opacity(0.8))
                                                    .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                                            }
                                        }
                                    )
                                    .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(4)
                    .background(.ultraThinMaterial)
                    .cornerRadius(14)
                    .shadow(color: Color.black.opacity(0.12), radius: 16, x: 0, y: 4)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
        }
        .frame(height: UIScreen.main.bounds.width * 1.3) // Aspect ratio for t-shirt
    }

    // MARK: - 2. Upload Section (Mobile-Optimized)
    private var uploadSectionMobile: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Upload & Extract Design")
                .font(.title3)
                .fontWeight(.bold)

            Text("Upload a photo and we'll extract the design using AI")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            // AI Disclaimer
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(.blue)
                    .font(.body)
                Text("AI extraction may require multiple tries for best results")
                    .font(.caption)
                    .foregroundColor(.blue)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.blue.opacity(0.1))
            .cornerRadius(10)

            // Upload button - Large, prominent
            PhotosPicker(selection: $selectedPhoto, matching: .images) {
                VStack(spacing: 16) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.blue)

                    VStack(spacing: 4) {
                        Text("Tap to Upload Photo")
                            .font(.headline)
                            .foregroundColor(.primary)

                        Text("JPG or PNG up to 25MB")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 50)
                .background(Color.white)
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(
                            style: StrokeStyle(lineWidth: 2, dash: [8, 6])
                        )
                        .foregroundColor(.blue.opacity(0.5))
                )
            }
            .disabled(viewModel.isExtracting)
        }
    }

    // MARK: - Extraction Status (Conditional)
    @ViewBuilder
    private var extractionStatusSection: some View {
        if viewModel.isExtracting {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("Stealing your t-shirt...")
                        .font(.headline)
                    Spacer()
                    ProgressView()
                }

                ProgressView(value: viewModel.extractionPercent)
                    .progressViewStyle(.linear)
                    .tint(.blue)
                    .scaleEffect(y: 1.5)

                Text(viewModel.extractionProgress)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(20)
            .background(Color.blue.opacity(0.1))
            .cornerRadius(16)
        } else if !viewModel.extractedAssets.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.title2)
                    Text("Extraction Complete!")
                        .font(.headline)
                        .foregroundColor(.green)
                }

                Text("Logo extracted! Drag it to position on your shirt.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(20)
            .background(Color.green.opacity(0.1))
            .cornerRadius(16)
        } else if let error = viewModel.errorMessage {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.red)
                        .font(.title2)
                    Text("Error")
                        .font(.headline)
                        .foregroundColor(.red)
                }

                Text(error)
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Button("Try Again") {
                    viewModel.errorMessage = nil
                }
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(Color.red)
                .cornerRadius(10)
            }
            .padding(20)
            .background(Color.red.opacity(0.1))
            .cornerRadius(16)
        }
    }

    // MARK: - 3. Color Selector (Horizontal Scroll)
    private var colorSelectorMobile: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("T-Shirt Color")
                .font(.title3)
                .fontWeight(.bold)
                .padding(.horizontal, 20)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(tshirtColors, id: \.self) { color in
                        Button {
                            selectedColor = color
                        } label: {
                            VStack(spacing: 12) {
                                Circle()
                                    .fill(colorForName(color))
                                    .frame(width: 60, height: 60)
                                    .overlay(
                                        Circle()
                                            .strokeBorder(Color.gray.opacity(0.3), lineWidth: 1)
                                    )
                                    .overlay(
                                        Circle()
                                            .strokeBorder(
                                                Color.black,
                                                lineWidth: selectedColor == color ? 3 : 0
                                            )
                                    )

                                Text(color)
                                    .font(.subheadline)
                                    .fontWeight(selectedColor == color ? .bold : .regular)
                                    .foregroundColor(.primary)
                            }
                            .padding(12)
                            .background(selectedColor == color ? Color.black.opacity(0.05) : Color.clear)
                            .cornerRadius(12)
                        }
                        .frame(minWidth: 44, minHeight: 44)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }

    // MARK: - 4. Size Selector (Grid)
    private var sizeSelectorMobile: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Size")
                .font(.title3)
                .fontWeight(.bold)

            LazyVGrid(
                columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ],
                spacing: 12
            ) {
                ForEach(sizes, id: \.self) { size in
                    Button {
                        selectedSize = size
                    } label: {
                        Text(size)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(selectedSize == size ? .white : .primary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(selectedSize == size ? Color.black : Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .strokeBorder(
                                        selectedSize == size ? Color.black : Color.gray.opacity(0.3),
                                        lineWidth: selectedSize == size ? 2 : 1
                                    )
                            )
                    }
                }
            }
        }
    }

    // MARK: - 5. Quantity & Price (Combined Card)
    private var quantityAndPriceSection: some View {
        VStack(spacing: 16) {
            // Quantity stepper
            HStack {
                Text("Quantity")
                    .font(.title3)
                    .fontWeight(.bold)

                Spacer()

                HStack(spacing: 20) {
                    Button {
                        if quantity > 1 { quantity -= 1 }
                    } label: {
                        Image(systemName: "minus.circle.fill")
                            .font(.title)
                            .foregroundColor(quantity > 1 ? .black : .gray)
                    }
                    .frame(minWidth: 44, minHeight: 44)
                    .disabled(quantity <= 1)

                    Text("\(quantity)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .frame(minWidth: 40)

                    Button {
                        quantity += 1
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title)
                            .foregroundColor(.black)
                    }
                    .frame(minWidth: 44, minHeight: 44)
                }
            }
            .padding(20)
            .background(Color(UIColor.systemGray6))
            .cornerRadius(16)

            // Price breakdown
            VStack(spacing: 12) {
                HStack {
                    Text("Unit Price")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("$\(String(format: "%.2f", unitPrice))")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }

                if quantity > 1 {
                    Divider()

                    HStack {
                        Text("Total")
                            .font(.headline)
                            .fontWeight(.bold)
                        Spacer()
                        Text("$\(String(format: "%.2f", totalPrice))")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                }
            }
            .padding(20)
            .background(Color.white)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(Color.gray.opacity(0.2), lineWidth: 1)
            )
        }
    }

    // MARK: - 6. Action Buttons
    private var actionButtonsSection: some View {
        VStack(spacing: 12) {
            // Primary CTA - Add to Cart
            Button {
                handleAddToCart()
            } label: {
                Text("Add to Cart")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(canAddToCart ? Color.black : Color.gray)
                    .cornerRadius(16)
            }
            .disabled(!canAddToCart)

            // Secondary actions
            HStack(spacing: 12) {
                Button(action: handleDownloadDesign) {
                    HStack {
                        Image(systemName: "arrow.down.circle")
                        Text("Download")
                    }
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(Color.white)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                }

                Button(action: handleSaveDesign) {
                    HStack {
                        Image(systemName: "heart")
                        Text("Save")
                    }
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(Color.white)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                }
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
        // Construct image URL based on selected color and current view
        // Format: {color}-{view}.png (e.g., "black-front.png", "navy-back.png")
        // For hoodies: hoodie-{color}-{view}.png (e.g., "hoodie-black-front.png")
        let colorName = selectedColor.lowercased()
        let viewName: String

        switch viewModel.currentView {
        case .front:
            viewName = "front"
        case .back:
            viewName = "back"
        case .neck:
            viewName = "neck"
        }

        // Check if current product is a hoodie
        let isHoodie = product.slug.lowercased().contains("hoodie")

        let baseURL = "https://dntnjlodfcojzgovikic.supabase.co/storage/v1/object/public/product-images/mockups"
        let imageFileName: String
        if isHoodie {
            // Hoodies don't have neck view, and use "hoodie-" prefix
            if viewName == "neck" {
                // Fallback to front view for hoodies (they don't have neck view)
                imageFileName = "hoodie-\(colorName)-front.png"
            } else {
                imageFileName = "hoodie-\(colorName)-\(viewName).png"
            }
        } else {
            // T-shirts use simple color-view format
            imageFileName = "\(colorName)-\(viewName).png"
        }
        let fullURL = "\(baseURL)/\(imageFileName)"

        guard let imageURL = URL(string: fullURL) else {
            // Fallback to placeholder if URL construction fails
            createPlaceholderBackground()
            return
        }

        // Load image asynchronously
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: imageURL)
                if let loadedImage = UIImage(data: data) {
                    await MainActor.run {
                        backgroundImage = loadedImage
                        updateCanvasBounds(for: loadedImage.size)
                    }
                } else {
                    // Image data couldn't be converted to UIImage
                    createPlaceholderBackground()
                }
            } catch {
                print("Failed to load product image from \(fullURL): \(error)")
                createPlaceholderBackground()
            }
        }
    }

    private func createPlaceholderBackground() {
        let backgroundColor: UIColor
        switch selectedColor.lowercased() {
        case "black":
            backgroundColor = .black
        case "navy":
            backgroundColor = UIColor(red: 0, green: 0.12, blue: 0.25, alpha: 1.0)
        default:
            backgroundColor = .white
        }

        let size = CGSize(width: 600, height: 700)
        let renderer = UIGraphicsImageRenderer(size: size)

        let image = renderer.image { context in
            backgroundColor.setFill()
            let rect = CGRect(origin: .zero, size: size)
            context.fill(rect)

            if selectedColor.lowercased() == "white" {
                context.cgContext.setStrokeColor(UIColor.black.withAlphaComponent(0.2).cgColor)
                context.cgContext.setLineWidth(2)
                context.cgContext.stroke(rect)
            }

            let label: String
            switch viewModel.currentView {
            case .front:
                label = "FRONT"
            case .back:
                label = "BACK"
            case .neck:
                label = "NECK"
            }

            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 24, weight: .light),
                .foregroundColor: selectedColor.lowercased() == "white" ? UIColor.black.withAlphaComponent(0.1) : UIColor.white.withAlphaComponent(0.1)
            ]
            let attributedString = NSAttributedString(string: label, attributes: attributes)
            let stringSize = attributedString.size()
            let stringRect = CGRect(
                x: (size.width - stringSize.width) / 2,
                y: size.height - stringSize.height - 40,
                width: stringSize.width,
                height: stringSize.height
            )
            attributedString.draw(in: stringRect)
        }

        backgroundImage = image
        updateCanvasBounds(for: size)
    }

    private func updateCanvasBounds(for imageSize: CGSize) {
        let aspectRatio = imageSize.width / imageSize.height
        let screenWidth = UIScreen.main.bounds.width

        // Edge-to-edge: Use full screen width
        var width = screenWidth
        var height = width / aspectRatio

        // Allow more height for natural t-shirt proportions
        let maxHeight = screenWidth * 1.4  // Taller aspect ratio for t-shirts

        if height > maxHeight {
            height = maxHeight
            width = height * aspectRatio
        }

        canvasBounds = CGRect(x: 0, y: 0, width: width, height: height)
    }

    private func updateCanvasForView() {
        updateBackgroundImage()
        syncLayersFromViewModel()
    }

    private func syncLayersFromViewModel() {
        canvasLayers = []

        for canvasObj in viewModel.canvasObjects {
            guard canvasObj.type == "image",
                  let urlString = canvasObj.imageUrl,
                  let url = URL(string: urlString) else {
                continue
            }

            // Load from Supabase storage
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
                // Upload via ViewModel -> Backend -> Gemini
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

        viewModel.addAssetToCanvas(transparentAsset)

        // Load extracted image from Supabase
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
        showToastMessage("Design saved!", type: .success)
    }

    private func handleDownloadDesign() {
        showToastMessage("Design downloaded!", type: .success)
    }

    private func handleAddToCart() {
        guard !selectedColor.isEmpty && !selectedSize.isEmpty else {
            alertMessage = "Please select color and size"
            showingAlert = true
            return
        }

        // Find the variant that matches selected color and size
        guard let variant = variants.first(where: {
            $0.color.lowercased() == selectedColor.lowercased() &&
            $0.size == selectedSize
        }) else {
            alertMessage = "Selected variant not available"
            showingAlert = true
            return
        }

        // Create customization spec from canvas objects
        let artworkAssets = viewModel.canvasObjects
            .compactMap { $0.imageUrl }
            .filter { !$0.isEmpty }

        let placements = viewModel.canvasObjects.map { obj in
            Placement(
                location: viewModel.currentView.rawValue,
                x: obj.x,
                y: obj.y,
                width: obj.width,
                height: obj.height,
                artworkId: obj.imageUrl,
                textElementId: nil,
                colors: [],
                rotation: obj.rotation
            )
        }

        let customSpec = CustomizationSpec(
            method: "dtg", // Direct to garment printing
            placements: placements,
            textElements: nil,
            artworkAssets: artworkAssets,
            notes: nil
        )

        // Add to cart
        cartViewModel.addItem(
            variant: variant,
            product: product,
            quantity: quantity,
            customSpec: customSpec,
            mockupUrl: nil, // Could generate a preview here
            unitPrice: Double(variant.basePrice) ?? 0.0
        )

        showToastMessage("Added to cart!", type: .success)
    }

    private func showToastMessage(_ message: String, type: ToastView.ToastType = .info) {
        toastMessage = message
        toastType = type
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
