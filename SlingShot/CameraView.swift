//
//  CameraView.swift
//  SlingShot
//
//  Created by Kailash on 25/03/24.
//

import SwiftUI
import AVKit

struct CameraView: UIViewRepresentable {
    let frameSize: CGSize
    @Binding var session: AVCaptureSession
    func makeUIView(context: Context) -> UIView {
        let view = UIViewType(frame: CGRect(origin: .zero, size: frameSize))
        view.backgroundColor = .clear
        
        let camera = AVCaptureVideoPreviewLayer(session: session)
        camera.frame = .init(origin: .zero, size: frameSize)
        camera.videoGravity = .resizeAspectFill
        camera.masksToBounds = true
        
        // Create circular mask layer
        let circularMaskLayer = CAShapeLayer()
        let circularPath = UIBezierPath(ovalIn: CGRect(origin: .zero, size: frameSize))
        circularMaskLayer.path = circularPath.cgPath
        camera.mask = circularMaskLayer
        
        view.layer.addSublayer(camera)
        return view
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
}

