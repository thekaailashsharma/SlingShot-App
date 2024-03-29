//
//  ContentView.swift
//  SlingShot
//
//  Created by Kailash on 24/03/24.
//

import SwiftUI
import AVKit

struct ContentView: View {
    let avatars = [
       "avatar1",  "avatar2",  "avatar3",  "avatar4", "avatar5", "avatar6"
    ]
    var background = #colorLiteral(red: 0.8892790675, green: 0.7262690663, blue: 0, alpha: 1)
    @State private var circleOffset: CGFloat = -100
    @State private var circleSize: CGFloat = 50
    @State private var isDragging: Bool = false
    @State private var avatarScale: CGFloat = 1.0
    @State private var avatarOffset: CGFloat = 0.0
    @State private var dragOffset: CGFloat = 0.0
    let dragThreshold: CGFloat = 20
    
    @State private var session: AVCaptureSession = .init()
    @State private var session2: AVCaptureSession = .init()
    @State private var errorMessage: String = ""
    @State private var text: String = "Release to take a SlingShot"
    @State private var color: Color = .white
    @State private var trim: CGFloat = 0.0
    @State private var deliveredOffset: CGFloat = -100.0
    @State private var showError: Bool = false
    @State private var isFront: Bool = false
    @State private var cameraPermissions: Permissions = .idle
    @State var cameraPosition: AVCaptureDevice.Position = .back
    @State private var output: AVCaptureMetadataOutput = .init()
    @State private var output2: AVCaptureMetadataOutput = .init()
    @State private var capturedImage: UIImage?
    
    var body: some View {
        NavigationStack {
            VStack {
                if isDragging {
                    
                    GeometryReader { proxy in
                        let size = proxy.size
                        VStack {
                            ZStack {
                                CameraView(frameSize: CGSize(width: size.width, height: size.width), session: isFront ? $session2 : $session)
                                    .offset(y: circleOffset + 200)
                                    .frame(width: size.width, height: size.height)
                                    .animation(.linear(duration: 1), value: circleOffset + 200)
                                
                                Circle()
                                    .trim(from: 0.0, to: text == "Fun!" ? trim : 1.0)
                                    .stroke(color, lineWidth: 4)
                                    .frame(width: size.width, height: size.width)
                                    .offset(y: circleOffset  + 200)
                                    .animation(.linear(duration: 1), value: circleOffset + 200)
                            }
                            
                            
                            Text(text)
                                .font(.footnote)
                                .foregroundColor(.white)
                                .fontWeight(.semibold)
                                .padding(.top)
                                .offset(y: circleOffset + 30)
                        }
                       
                    }
                    .offset(y: -65)
                    .frame(width: 300, height: 300)
                    
                }
                VStack(spacing: 0) {
                    Text("Pull Down to Reveal The Camera")
                        .font(.footnote)
                        .foregroundColor(.white)
                        .fontWeight(.semibold)
                        .padding(.top)
                        .offset(y: 30)
                    Image("arrow")
                        .resizable()
                        .frame(width: 200, height: 300)
                }
                .opacity(isDragging ? 0: 1)
                .animation(.easeInOut, value: isDragging)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .top, spacing: 16) {
                        ForEach(avatars, id: \.self) { avatar in
                            
                            GeometryReader { proxy in
                                let scale = getScale(proxy: proxy)
                                
                                VStack(spacing: 8) {
                                    
                                    Image(avatar)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 180)
                                        .shadow(radius: 10)
                                        .clipped()
                                        .cornerRadius(8)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color(white: 0.4))
                                        )
                                        .shadow(radius: 3)
                                        .scaleEffect(CGSize(width: avatarScale, height: avatarScale))
                                        .offset(y: avatarOffset)
                                        .animation(.linear(duration: 1), value: avatarScale)
                                        .simultaneousGesture(
                                            scale > 1.0 ? DragGesture()
                                                .onChanged({ gesture in
                                                    let translation = gesture.translation.height
                                                    if translation > 0 {
                                                        if !isDragging && abs(translation) > dragThreshold {
                                                            isDragging = true
                                                            dragOffset = translation
                                                        }
                                                        if isDragging {
                                                            circleOffset = max(-100, translation - dragOffset)
                                                            
                                                            
                                                            let newSize = min(max(50 + circleOffset, 50), 300)
                                                            circleSize = newSize
                                                            
                                                            
                                                            if circleOffset >= -50 {
                                                                let scaleRatio = 1.0 - (abs(circleOffset + 100) / 150)
                                                                avatarScale = max(0.5, scaleRatio)
                                                                avatarOffset = min(0.0, (circleOffset + 100) / 2)
                                                            }
                                                        }
                                                    }
                                                })
                                                .onEnded({ gesture in
                                                    withAnimation(.spring(duration: 1.0)) {
                                                        text = "Fun!"
                                                        color = .green
                                                        trim = 1.0
                                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                                            withAnimation {
                                                                isDragging = false
                                                                circleOffset = -100
                                                                avatarScale = 1.0
                                                                avatarOffset = 0.0
                                                                text = "Release to take a SlingShot"
                                                                color = .white
                                                                trim = 0.0
                                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                                                    withAnimation(.spring()){
                                                                        deliveredOffset = 0.0
                                                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                                                            withAnimation(.spring()){
                                                                                deliveredOffset = -100.0
                                                                            }
                                                                        }
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    }
                                                }) : nil
                                        )
                                    
                                    Button(action: {
                                        cameraPosition = (cameraPosition == .back) ? .front : .back
                                    }, label: {
                                        Text(cameraPosition == .back ? "Back" : "Front")
                                    })
                                }
                                .scaleEffect(.init(width: scale, height: scale))
                                .animation(.easeOut(duration: 1), value: scale)
                                .padding(.vertical)
                            }
                            .frame(width: 70, height: 300)
                            .padding(.horizontal, 80)
                            .padding(.vertical, 32)
                        }
                        Spacer()
                            .frame(width: 16)
                    }
                }
                .simultaneousGesture(DragGesture())
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(uiColor: background).opacity(0.95))
            .onAppear(perform: {
                checkCameraPermission()
            })
            .safeAreaInset(edge: .top, alignment: .center) {
                if deliveredOffset > -100.0 {
                    Text("Delivered")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .padding()
                        .background(.black)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .offset(y: deliveredOffset)
                }
            }
        }
        .safeAreaInset(edge: .bottom, alignment: .trailing) {
            Image(systemName: !isFront ? "web.camera" : "iphone.rear.camera")
                .resizable()
                .frame(width: 35, height: 35)
                .foregroundStyle(.white)
                .padding()
                .background(.black.opacity(0.5))
                .clipShape(Circle())
                .padding(.trailing, 8)
                .onTapGesture {
                    withAnimation {
                        isFront.toggle()
                    }
                }
                
        }
        
    }
    
    func setupCameraFront() {
        do {
            guard let device = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .front).devices.first else {
                return
            }
            
            let input = try AVCaptureDeviceInput(device: device)
            session2.beginConfiguration()
            session2.addInput(input)
            session2.addOutput(output2)
            session2.commitConfiguration()
            DispatchQueue.global(qos: .background).async {
                session2.startRunning()
            }
            
        } catch  {
            print("Errorr is \(error.localizedDescription)")
        }
    }
    
    func setupCamera() {
        do {
            guard let device = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInDualCamera], mediaType: .video, position: .back).devices.first else {
                return
            }
            
            let input = try AVCaptureDeviceInput(device: device)
            session.beginConfiguration()
            session.addInput(input)
            session.addOutput(output)
            session.commitConfiguration()
            DispatchQueue.global(qos: .background).async {
                session.startRunning()
            }
            
        } catch  {
            print("Errorr is \(error.localizedDescription)")
        }
    }
    
    func getScale(proxy: GeometryProxy) -> CGFloat {
        let midPoint: CGFloat = 125
        
        let viewFrame = proxy.frame(in: CoordinateSpace.global)
        
        var scale: CGFloat = 1.0
        let deltaXAnimationThreshold: CGFloat = 125
        
        let diffFromCenter = abs(midPoint - viewFrame.origin.x - deltaXAnimationThreshold / 2)
        if diffFromCenter < deltaXAnimationThreshold {
            scale = 1 + (deltaXAnimationThreshold - diffFromCenter) / 500
        }
        
        return scale
    }
    
    func checkCameraPermission() {
        Task {
            switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .notDetermined:
                if await AVCaptureDevice.requestAccess(for: .video) {
                    cameraPermissions = .approved
                    setupCamera()
                    setupCameraFront()
                } else {
                    cameraPermissions = .denied
                }
            case .restricted:
                cameraPermissions = .denied
            case .denied:
                cameraPermissions = .denied
            case .authorized:
                cameraPermissions = .approved
                setupCamera()
                setupCameraFront()
            @unknown default:
                break
            }
        }
    }
}



#Preview {
    ContentView()
}

enum Permissions: String {
    case idle = "Not Determined"
    case approved = "Access Granted"
    case denied = "Access Denied"
}
