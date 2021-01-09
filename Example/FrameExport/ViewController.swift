//
//  ViewController.swift
//  FrameExport
//
//  Created by Martin on 01/06/2021.
//  Copyright (c) 2021 Martin. All rights reserved.
//

import UIKit
import PhotosUI
import FrameExport

class ViewController: UIViewController {
    
    private var frameExport: FrameExport?
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func activity(_ state: Bool) {
        DispatchQueue.main.async {
            if state {
                self.activityIndicator.startAnimating()
            } else {
                self.activityIndicator.stopAnimating()
            }
        }
    }
    
    @IBAction func selectVideo(_ sender: Any) {
        
        var configuration = PHPickerConfiguration()
        configuration.filter = .videos
        configuration.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: configuration)
        
        picker.delegate = self
        
        present(picker, animated: true, completion: nil)
        
    }
    
}

extension ViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)
        
        guard results.indices.contains(0) else {return}
        
        let result = results[0]
        
        if result.itemProvider.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
            result.itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { [self] rawurl, error in
                guard error == nil, let url: URL = rawurl else {return}
                
                activity(true)
                
                let fileManager = FileManager.default

                let documentsUrl = fileManager.urls(for: .documentDirectory,
                                                        in: .userDomainMask)
                

                let dest = documentsUrl.first!.appendingPathComponent("temp.mov")
                
                do {
                    try? fileManager.removeItem(at: dest)
                    try fileManager.copyItem(at: url, to: dest)
                } catch {
                    print("Error copying file...")
                    activity(false)
                }
                
                let completion = { [weak self] (status: FrameExport.Status) in
                    DispatchQueue.main.async {
                        
                        switch status {
                        case .cancelled:
                            print("Export Canceled")
                            activity(false)
                        case .failed(let err):
                            print("Export failed")
                            activity(false)
                            dump(err)
                        case .progressed(let urls):
                            print("Progress... \(urls.count)")
                        case .succeeded(let urls):
                            print("Succeded exporting \(urls.count) frames")
                            
                            for url in urls {
                                guard let image = UIImage(contentsOfFile: url.path) else {
                                    print("Can't load image")
                                    continue
                                }
                                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                            }
                            
                            self?.frameExport = nil
                            activity(false)
                            
                        }
                    }
                }
                
                let asset = AVAsset(url: dest)
                
                let encoding = FrameExport.ImageEncoding(format: .heif, compressionQuality: 1)
                
                let request = FrameExport.Request(video: asset, fps: 1, encoding: encoding)
                
                self.frameExport = FrameExport(request: request, updateHandler: completion)
                
                self.frameExport?.start()
                
            }
        }
        
    }
    
    
}
