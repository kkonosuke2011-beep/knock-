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
        VStack(spacing: 16) {
            Text(subject.rawValue)
                .font(.title2)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)

            if camera.authorizationDenied {
                ContentUnavailableView(
                    "カメラを使えません",
                    systemImage: "camera.fill",
                    description: Text("設定からカメラの許可を有効にしてください。")
                )
                .frame(maxHeight: .infinity)
            } else {
                ZStack(alignment: .bottom) {
                    Group {
                        if let capturedImage = camera.capturedImage {
                            Image(uiImage: capturedImage)
                                .resizable()
                                .scaledToFit()
                        } else {
                            CameraPreview(session: camera.session)
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                    HStack(spacing: 12) {
                        Button("再撮影") {
                            camera.resetCapture()
                        }
                        .buttonStyle(SecondaryButtonStyle())

                        Button {
                            runOCR()
                        } label: {
                            HStack(spacing: 8) {
                                if isRunningOCR {
                                    ProgressView()
                                        .progressViewStyle(.circular)
                                }
                                Text("この教科で進む")
                            }
                        }
                        .buttonStyle(PrimaryButtonStyle())
                        .disabled(camera.capturedImage == nil || isRunningOCR)
                    }
                    .padding()
                }
                .frame(maxHeight: .infinity)
            }

            Button {
                camera.capturePhoto()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "circle.inset.filled")
                    Text(camera.capturedImage == nil ? "撮影する" : "撮り直す")
                }
            }
            .buttonStyle(PrimaryButtonStyle())
            .disabled(camera.authorizationDenied)
        }
        .padding()
        .navigationTitle(subject.rawValue)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            camera.start()
        }
        .onDisappear {
            camera.stop()
        }
        .navigationDestination(isPresented: $navigateToAnswerMode) {
            AIServiceView(
                subject: subject.rawValue,
                recognizedText: recognizedText
            )
        }
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
    let photoOutput = AVCapturePhotoOutput()

    @Published var capturedImage: UIImage?
    @Published var authorizationDenied = false

    private let sessionQueue = DispatchQueue(label: "camera.session.queue")
    private var configured = false

    func start() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            startSession()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    self?.authorizationDenied = !granted
                    if granted {
                        self?.startSession()
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

    func resetCapture() {
        capturedImage = nil
        startSession()
    }

    func capturePhoto() {
        guard capturedImage == nil else {
            resetCapture()
            return
        }

        let settings = AVCapturePhotoSettings()
        settings.flashMode = .auto
        photoOutput.capturePhoto(with: settings, delegate: self)
    }

    private func startSession() {
        sessionQueue.async {
            self.configureIfNeeded()
            guard !self.session.isRunning else { return }
            self.session.startRunning()
        }
    }

    private func configureIfNeeded() {
        guard !configured else { return }

        session.beginConfiguration()
        session.sessionPreset = .photo

        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: device),
              session.canAddInput(input),
              session.canAddOutput(photoOutput) else {
            session.commitConfiguration()
            return
        }

        session.addInput(input)
        session.addOutput(photoOutput)
        session.commitConfiguration()
        configured = true
    }

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
            self.stop()
        }
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
