import SwiftUI
import AVFoundation
import Combine

struct CameraView: View {
    let subject: Subject

    @StateObject private var camera = CameraController()
    @State private var recognizedText = ""
    @State private var isRunningOCR = false
    @State private var navigateToAnswerMode = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if camera.authorizationDenied {
                unavailableCameraView
            } else {
                cameraPreview
                    .ignoresSafeArea()
            }

            VStack {
                Spacer()
                controls
                    .padding()
            }
        }
        .navigationTitle(subject.rawValue)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .onAppear(perform: camera.start)
        .onDisappear(perform: camera.stop)
        .navigationDestination(isPresented: $navigateToAnswerMode) {
            AIServiceView(
                subject: subject.rawValue,
                recognizedText: recognizedText
            )
        }
    }

    @ViewBuilder
    private var controls: some View {
        if camera.capturedImage == nil {
            shutterButton
        } else {
            confirmationButtons
        }
    }

    private var unavailableCameraView: some View {
        ContentUnavailableView(
            "カメラを使えません",
            systemImage: "camera.fill",
            description: Text("設定からカメラの許可を有効にしてください。")
        )
    }

    @ViewBuilder
    private var cameraPreview: some View {
        if let capturedImage = camera.capturedImage {
            Image(uiImage: capturedImage)
                .resizable()
                .scaledToFit()
        } else {
            CameraPreview(session: camera.session)
        }
    }

    private var confirmationButtons: some View {
        HStack(spacing: 12) {
            Button("再撮影", action: camera.resetCapture)
                .buttonStyle(SecondaryButtonStyle())

            Button(action: runOCR) {
                HStack(spacing: 8) {
                    if isRunningOCR {
                        ProgressView()
                            .progressViewStyle(.circular)
                    }
                    Text("この教科で進む")
                }
            }
            .buttonStyle(PrimaryButtonStyle())
            .disabled(isRunningOCR)
        }
    }

    private var shutterButton: some View {
        Button(action: camera.capturePhoto) {
            HStack(spacing: 8) {
                Image(systemName: "circle.inset.filled")
                Text("撮影する")
            }
        }
        .buttonStyle(PrimaryButtonStyle())
        .disabled(camera.authorizationDenied)
    }

    private func runOCR() {
        guard let image = camera.capturedImage else { return }

        isRunningOCR = true
        OCRService.recognizeText(from: image) { text in
            recognizedText = text
            isRunningOCR = false
            navigateToAnswerMode = true
        }
    }
}

final class CameraController: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate {
    let session = AVCaptureSession()
    private let photoOutput = AVCapturePhotoOutput()
    private let sessionQueue = DispatchQueue(label: "camera.session.queue")
    private var isConfigured = false

    @Published var capturedImage: UIImage?
    @Published var authorizationDenied = false

    // MARK: - Session Lifecycle

    func start() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            authorizationDenied = false
            configureAndStart()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    self?.authorizationDenied = !granted
                    if granted {
                        self?.configureAndStart()
                    }
                }
            }
        default:
            authorizationDenied = true
        }
    }

    func stop() {
        sessionQueue.async {
            guard self.session.isRunning else { return }
            self.session.stopRunning()
        }
    }

    // MARK: - Capture

    func capturePhoto() {
        // 撮影済みなら再撮影に切り替える
        guard capturedImage == nil else {
            resetCapture()
            return
        }

        sessionQueue.async {
            guard self.session.isRunning else { return }
            let settings = AVCapturePhotoSettings()
            settings.flashMode = .auto
            self.photoOutput.capturePhoto(with: settings, delegate: self)
        }
    }

    func resetCapture() {
        capturedImage = nil
        configureAndStart()
    }

    // MARK: - Setup

    private func configureAndStart() {
        sessionQueue.async {
            guard self.configureIfNeeded(), !self.session.isRunning else { return }
            self.session.startRunning()
        }
    }

    private func configureIfNeeded() -> Bool {
        guard !isConfigured else { return true }

        session.beginConfiguration()
        session.sessionPreset = .photo

        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: device),
              session.canAddInput(input),
              session.canAddOutput(photoOutput) else {
            session.commitConfiguration()
            return false
        }

        session.addInput(input)
        session.addOutput(photoOutput)
        session.commitConfiguration()
        isConfigured = true
        return true
    }

    // MARK: - AVCapturePhotoCaptureDelegate

    func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto,
        error: Error?
    ) {
        guard error == nil,
              let data = photo.fileDataRepresentation(),
              let image = UIImage(data: data) else { return }

        DispatchQueue.main.async {
            self.capturedImage = image
        }
        stop()
    }
}

struct CameraPreview: UIViewRepresentable {
    let session: AVCaptureSession

    func makeUIView(context: Context) -> PreviewView {
        let view = PreviewView()
        view.videoPreviewLayer.session = session
        view.videoPreviewLayer.videoGravity = .resizeAspectFill
        return view
    }

    func updateUIView(_ uiView: PreviewView, context: Context) {
        uiView.videoPreviewLayer.session = session
    }
}

final class PreviewView: UIView {
    override class var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
    }

    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        layer as! AVCaptureVideoPreviewLayer
    }
}

private struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.title3)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue.opacity(configuration.isPressed ? 0.8 : 1))
            .foregroundColor(.white)
            .cornerRadius(12)
    }
}

private struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.title3)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.gray.opacity(configuration.isPressed ? 0.18 : 0.12))
            .foregroundColor(.primary)
            .cornerRadius(12)
    }
}

#Preview {
    NavigationStack {
        CameraView(subject: .math)
    }
}
