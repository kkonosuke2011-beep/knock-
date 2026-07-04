import SwiftUI

struct CropView: View {
    enum CropRatio: String, CaseIterable, Identifiable {
        case free = "Free"
        case square = "1:1"
        case fourThree = "4:3"
        case sixteenNine = "16:9"

        var id: String { rawValue }

        var value: CGFloat? {
            switch self {
            case .free: return nil
            case .square: return 1.0
            case .fourThree: return 4.0 / 3.0
            case .sixteenNine: return 16.0 / 9.0
            }
        }
    }

    let image: UIImage
    let onCancel: () -> Void
    let onCropped: (UIImage) -> Void
    @State private var workingImage: UIImage

    @State private var cropRect = CGRect.zero
    @State private var didInitRect = false
    @State private var cropRatio: CropRatio = .free
    @State private var dragStartRect = CGRect.zero
    @State private var resizeStartRect = CGRect.zero

    private let minCropSize: CGFloat = 80

    init(
        image: UIImage,
        onCancel: @escaping () -> Void,
        onCropped: @escaping (UIImage) -> Void
    ) {
        self.image = image
        self.onCancel = onCancel
        self.onCropped = onCropped
        _workingImage = State(initialValue: image.normalizedOrientation())
    }

    var body: some View {
        GeometryReader { geometry in
            let imageFrame = fittedImageFrame(in: geometry.size)

            ZStack {
                Color.black.ignoresSafeArea()

                Image(uiImage: workingImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: geometry.size.width, height: geometry.size.height)

                Color.black.opacity(0.45)
                    .mask(
                        Rectangle()
                            .overlay(
                                Rectangle()
                                    .frame(width: cropRect.width, height: cropRect.height)
                                    .position(x: cropRect.midX, y: cropRect.midY)
                                    .blendMode(.destinationOut)
                            )
                    )
                    .compositingGroup()

                Rectangle()
                    .stroke(Color.yellow, lineWidth: 5)
                    .frame(width: cropRect.width, height: cropRect.height)
                    .position(x: cropRect.midX, y: cropRect.midY)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                if dragStartRect == .zero {
                                    dragStartRect = cropRect
                                }
                                let moved = dragStartRect.offsetBy(
                                    dx: value.translation.width,
                                    dy: value.translation.height
                                )
                                cropRect = clampedRect(moved, inside: imageFrame)
                            }
                            .onEnded { _ in
                                dragStartRect = .zero
                            }
                    )

                Circle()
                    .fill(Color.yellow)
                    .frame(width: 20, height: 20)
                    .position(x: cropRect.maxX, y: cropRect.maxY)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                if resizeStartRect == .zero {
                                    resizeStartRect = cropRect
                                }
                                cropRect = resizedRect(
                                    from: resizeStartRect,
                                    delta: value.translation,
                                    inside: imageFrame
                                )
                            }
                            .onEnded { _ in
                                resizeStartRect = .zero
                            }
                    )

                VStack {
                    HStack {
                        Button("キャンセル", action: onCancel)
                            .foregroundColor(.white)
                        Spacer()
                        Button("切り取り") {
                            if let cropped = cropImage(from: cropRect, imageFrame: imageFrame) {
                                onCropped(cropped)
                            }
                        }
                        .foregroundColor(.white)
                    }
                    .padding(.horizontal)
                    .padding(.top, 12)

                    Spacer()

                    Picker("比率", selection: $cropRatio) {
                        ForEach(CropRatio.allCases) { ratio in
                            Text(ratio.rawValue).tag(ratio)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    .padding(.bottom, 24)
                    .onChange(of: cropRatio) { _, _ in
                        applyRatio(in: imageFrame)
                    }
                }
            }
            .onAppear {
                if !didInitRect {
                    cropRect = initialRect(in: imageFrame)
                    didInitRect = true
                }
            }
        }
    }

    private func fittedImageFrame(in container: CGSize) -> CGRect {
        let imageSize = workingImage.size
        let imageAspect = imageSize.width / imageSize.height
        let containerAspect = container.width / container.height

        if imageAspect > containerAspect {
            let width = container.width
            let height = width / imageAspect
            return CGRect(x: 0, y: (container.height - height) / 2, width: width, height: height)
        } else {
            let height = container.height
            let width = height * imageAspect
            return CGRect(x: (container.width - width) / 2, y: 0, width: width, height: height)
        }
    }

    private func initialRect(in imageFrame: CGRect) -> CGRect {
        let width = imageFrame.width * 0.75
        let height = imageFrame.height * 0.5
        return CGRect(
            x: imageFrame.midX - (width / 2),
            y: imageFrame.midY - (height / 2),
            width: width,
            height: height
        )
    }

    private func clampedRect(_ rect: CGRect, inside bounds: CGRect) -> CGRect {
        var r = rect
        r.origin.x = min(max(r.origin.x, bounds.minX), bounds.maxX - r.width)
        r.origin.y = min(max(r.origin.y, bounds.minY), bounds.maxY - r.height)
        return r
    }

    private func resizedRect(from base: CGRect, delta: CGSize, inside bounds: CGRect) -> CGRect {
        var width = max(base.width + delta.width, minCropSize)
        var height = max(base.height + delta.height, minCropSize)

        if let ratio = cropRatio.value {
            height = width / ratio
            if height < minCropSize {
                height = minCropSize
                width = height * ratio
            }
        }

        width = min(width, bounds.maxX - base.minX)
        height = min(height, bounds.maxY - base.minY)

        if let ratio = cropRatio.value {
            let adjustedHeight = width / ratio
            if adjustedHeight <= (bounds.maxY - base.minY) {
                height = adjustedHeight
            } else {
                width = height * ratio
            }
        }

        return CGRect(x: base.minX, y: base.minY, width: width, height: height)
    }

    private func applyRatio(in imageFrame: CGRect) {
        guard let ratio = cropRatio.value else { return }

        var width = cropRect.width
        var height = width / ratio

        if height > imageFrame.maxY - cropRect.minY {
            height = imageFrame.maxY - cropRect.minY
            width = height * ratio
        }

        if width > imageFrame.maxX - cropRect.minX {
            width = imageFrame.maxX - cropRect.minX
            height = width / ratio
        }

        cropRect = CGRect(x: cropRect.minX, y: cropRect.minY, width: width, height: height)
        cropRect = clampedRect(cropRect, inside: imageFrame)
    }

    private func cropImage(from rect: CGRect, imageFrame: CGRect) -> UIImage? {
        guard let cgImage = workingImage.cgImage else { return nil }

        let scaleX = CGFloat(cgImage.width) / imageFrame.width
        let scaleY = CGFloat(cgImage.height) / imageFrame.height

        let x = (rect.minX - imageFrame.minX) * scaleX
        let y = (rect.minY - imageFrame.minY) * scaleY
        let width = rect.width * scaleX
        let height = rect.height * scaleY

        let crop = CGRect(x: x, y: y, width: width, height: height).integral
        guard let cropped = cgImage.cropping(to: crop) else { return nil }

        return UIImage(cgImage: cropped, scale: workingImage.scale, orientation: .up)
    }
}

private extension UIImage {
    func normalizedOrientation() -> UIImage {
        if imageOrientation == .up {
            return self
        }

        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
