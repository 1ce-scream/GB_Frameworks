//
//  PhotoViewController.swift
//  GB_Frameworks
//
//  Created by Vitaliy Talalay on 09.06.2022.
//

import UIKit
import AVFoundation

final class PhotoViewController: UIViewController {
    
    let capturePhotoButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .white
        button.tintColor = .white
        button.layer.cornerRadius = 25
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var viewModel: PhotoViewModel?
    
    private var captureSession: AVCaptureSession?
    private var cameraOutput: AVCapturePhotoOutput?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var deviceOrientationOnCapture: UIDeviceOrientation?
    
// MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let cameraOutput = makeCameraOutput()
        self.cameraOutput = cameraOutput
        
        guard
            let captureSession = makeCameraSession(cameraOutput: cameraOutput)
        else { return }
        
        self.captureSession = captureSession
        configurePreviewLayer(captureSession, cameraOutput)
        
        setupView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        checkPermissions()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        captureSession?.startRunning()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        captureSession?.stopRunning()
    }

// MARK: - View setups
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        previewLayer?.frame = view.layer.bounds
    }
    
    override func viewWillTransition(to size: CGSize,
                                     with coordinator: UIViewControllerTransitionCoordinator) {
        if previewLayer?.connection?.isVideoOrientationSupported == true {
            previewLayer?.connection?.videoOrientation = UIDevice.current
                .orientation.getAVCaptureVideoOrientationFromDevice()
        }
    }
    
    private func setupView(){
        view.backgroundColor = .black
        view.addSubview(capturePhotoButton)
        
        NSLayoutConstraint.activate([
            capturePhotoButton.centerXAnchor.constraint(equalTo: view
                .safeAreaLayoutGuide.centerXAnchor),
            capturePhotoButton.bottomAnchor.constraint(equalTo: view
                .safeAreaLayoutGuide.bottomAnchor, constant: -10),
            capturePhotoButton.widthAnchor.constraint(equalToConstant: 50),
            capturePhotoButton.heightAnchor.constraint(equalToConstant: 50),
        ])
        
        capturePhotoButton.addTarget(self,
                                     action: #selector(captureImage(_:)),
                                     for: .touchUpInside)
    }
    
    private func configurePreviewLayer(_ captureSession: AVCaptureSession,
                                       _ cameraOutput: AVCapturePhotoOutput) {
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        view.layer.insertSublayer(previewLayer, at: 0)
        previewLayer.frame = view.layer.bounds
        self.previewLayer = previewLayer
    }
}

// MARK: - Camera
extension PhotoViewController {
    private func cameraDeviceFind() -> AVCaptureDevice? {
        let discoverySession = AVCaptureDevice
            .DiscoverySession(deviceTypes: [.builtInWideAngleCamera],
                              mediaType: .video,
                              position: .front)
        let devices = discoverySession.devices
        
        let device = devices.first(where: {
            $0.hasMediaType(AVMediaType.video) && $0.position == .front
        })
        
        return device
    }
    
    private func makeCameraOutput() -> AVCapturePhotoOutput {
        let cameraOutput = AVCapturePhotoOutput()
        cameraOutput.isHighResolutionCaptureEnabled = true
        cameraOutput.isLivePhotoCaptureEnabled = false
        return cameraOutput
    }
    
    private func makeCameraSession(cameraOutput: AVCapturePhotoOutput) -> AVCaptureSession? {
        let captureSession = AVCaptureSession()
        
        guard
            let device = cameraDeviceFind(),
            let input = try? AVCaptureDeviceInput(device: device),
            captureSession.canAddInput(input)
        else { return nil }
        
        captureSession.addInput(input)
        
        if captureSession.canSetSessionPreset(.photo) {
            captureSession.sessionPreset = .photo
        }
        captureSession.automaticallyConfiguresCaptureDeviceForWideColor = true
        captureSession.addOutput(cameraOutput)
        
        return captureSession
    }
    
    private func checkPermissions() {
        let cameraAuthStatus =  AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        switch cameraAuthStatus {
          case .authorized:
            print("Camera permission allowed")
            return
          case .denied:
            print("Camera permission denied")
            viewModel?.backToMap()
          case .notDetermined:
            AVCaptureDevice.requestAccess(for: AVMediaType.video) { authorized in
              if !authorized {
                  print("Camera permission denied")
                  self.viewModel?.backToMap()
              }
            }
          case .restricted:
            print("Camera permission denied")
            viewModel?.backToMap()
          @unknown default:
            fatalError()
        }
    }
    
    @objc func captureImage(_ sender: Any) {
        let settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
        cameraOutput?.capturePhoto(with: settings, delegate: self)
    }
}

// MARK: - AVCapturePhotoDelegate
extension PhotoViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photo: AVCapturePhoto,
                     error: Error?) {
        guard
            let imageData = photo.fileDataRepresentation(),
            let uiImage = UIImage(data: imageData),
            let cgImage = uiImage.cgImage,
            let deviceOrientationOnCapture = self.deviceOrientationOnCapture
        else { return }
        
        let image = UIImage(cgImage: cgImage,
                            scale: 1.0,
                            orientation: deviceOrientationOnCapture.getUIImageOrientationFromDevice())
        viewModel?.onSelfie(photo: image)
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput,
                     willBeginCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
        deviceOrientationOnCapture = UIDevice.current.orientation
    }
}

// MARK: - UIDeviceOrientation
fileprivate extension UIDeviceOrientation {
    func getAVCaptureVideoOrientationFromDevice() -> AVCaptureVideoOrientation {
        let orientation: AVCaptureVideoOrientation
        switch self {
        case .unknown:
            orientation = .landscapeLeft
        case .portrait, .faceUp:
            orientation = .portrait
        case .portraitUpsideDown, .faceDown:
            orientation = .portraitUpsideDown
        case .landscapeLeft:
            orientation = .landscapeRight
        case .landscapeRight:
            orientation = .landscapeLeft
        @unknown default:
            fatalError()
        }
        return orientation
    }
    
    func getUIImageOrientationFromDevice() -> UIImage.Orientation {
        let orientation: UIImage.Orientation
        switch self {
        case .unknown:
            orientation = .right
        case .portrait, .faceUp:
            orientation = .right
        case .portraitUpsideDown, .faceDown:
            orientation = .left
        case .landscapeLeft:
            orientation = .down
        case .landscapeRight:
            orientation = .up
        @unknown default:
            fatalError()
        }
        return orientation
    }
}
