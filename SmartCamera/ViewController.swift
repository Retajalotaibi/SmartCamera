//
//  ViewController.swift
//  SmartCamera
//
//  Created by Retaj Al-Otaibi on 7/24/20.
//  Copyright © 2020 Retaj Al-Otaibi. All rights reserved.
//

import UIKit
import AVKit
import Vision
class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {

    @IBOutlet var imageView: UIView!
    @IBOutlet weak var label: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
     
        //MARK: - CAMERA 📷
        //her is where we start up the camera
        
        let capturSession = AVCaptureSession()
        capturSession.sessionPreset = .photo
        
        
        guard let captureDevice = AVCaptureDevice.default(for: .video) else {return} // needs to be unwrapped
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else {return}// the device could have no camers (throws error)
        
        // here we add input so the captur start (could be audio input or in oue case camra)
        capturSession.addInput(input)
        
        capturSession.startRunning()
        // seting the camera output
        let previewLayer = AVCaptureVideoPreviewLayer(session: capturSession)
        imageView.layer.addSublayer(previewLayer)
        previewLayer.frame = imageView.frame// setting frame
        
        // to check every frame
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        capturSession.addOutput(dataOutput)
        
        
        
    
    }

         //MARK: - analyse what the image 🤔
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {return}

              guard let model = try? VNCoreMLModel(for: Resnet50().model) else {return}
              let request = VNCoreMLRequest(model: model) { (finishedReq, err) in
                 
                  guard let results = finishedReq.results as? [VNClassificationObservation]else {return}
                  guard let firstObservation = results.first else {return}
                DispatchQueue.main.async {  self.label.text = "\(firstObservation.identifier)    \(firstObservation.confidence)"}
                  print("\(firstObservation.identifier)    \(firstObservation.confidence)")
              }
             try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
    }
}

