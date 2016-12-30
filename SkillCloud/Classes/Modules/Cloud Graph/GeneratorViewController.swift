//
//  GeneratorViewController.swift
//  SkillCloud
//
//  Created by Andrzej Michnia on 07/09/16.
//  Copyright © 2016 amichnia. All rights reserved.
//

import UIKit
import SpriteKit
import PromiseKit
import iRate
import MRProgress

class GeneratorViewController: CloudViewController {

    // MARK: - Outlets
    @IBOutlet weak var skView: SKView!
    @IBOutlet weak var overlayImageView: UIImageView!
    
    @IBOutlet weak var nodeToolbarSection: UIView!
    @IBOutlet weak var removeButton: UIButton!
    @IBOutlet weak var scaleContainer: TouchDownView!
    @IBOutlet weak var scaleLabel: UILabel!
    @IBOutlet weak var scaleImage: UIImageView!
    @IBOutlet weak var scaleProgress: UISlider!
    @IBOutlet weak var paletteButton: UIButton!
    
    // MARK: - Gesture recognizers
    @IBOutlet weak var pinchGestureRecognizer: UIPinchGestureRecognizer!
    @IBOutlet weak var tapGestureRecognizer: UITapGestureRecognizer!
    @IBOutlet weak var selectTapGestureRecognizer: UITapGestureRecognizer!
    @IBOutlet var selectPressGestureRecognizer: UILongPressGestureRecognizer!
    @IBOutlet weak var panGestureRecognizer: UIPanGestureRecognizer!
    @IBOutlet var scalePanGestureRecognizer: UIPanGestureRecognizer!
    
    // MARK: - Properties
    var scene : CloudGraphScene!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.scaleContainer.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let image = scaleImage.image?.withRenderingMode(.alwaysTemplate) {
            self.scaleImage.tintColor = UIColor.white
            self.scaleImage.image = image
            self.scaleImage.setNeedsDisplay()
        }
        else {
            assertionFailure()
        }
        
        skView.setNeedsLayout()
        configurePalette()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.prepareSceneIfNeeded(self.skView, size: self.skView.bounds.size)
    }
    
    // MARK: - Configuration
    func prepareSceneIfNeeded(_ skView: SKView, size: CGSize){
        if let scene = CloudGraphScene(fileNamed:"CloudGraphScene"), self.scene == nil {
            scene.scaleMode = .aspectFit
            scene.cloudDelegate = self
            scene.slot = self.slot
            scene.cloudIdentifier = self.cloudEntity?.cloudId ?? UUID().uuidString
            scene.cloudEntity = self.cloudEntity
            
            self.scene = scene
            skView.presentScene(scene)
        }
    }
    
    func configurePalette() {
        let size = CGSize(width: 30, height: 30)
        paletteButton.setImage(Palette.main.thumbnail(for: size), for: .normal)
        scene?.updateColor(palette: Palette.main)
    }
    
    // MARK: - Recognizers Actions
    @IBAction func zoomingAction(_ sender: UIPinchGestureRecognizer) {
        switch sender.state {
        case .began, .changed:
            self.scene.cameraZoom(sender.scale)
        case .ended:
            self.scene.cameraZoom(sender.scale, save: true)
        default:
            break
        }
    }
    
    @IBAction func tapAction(_ sender: UITapGestureRecognizer) {
        guard let skillToAdd = self.skillToAdd else {
            return
        }
        
        self.scene.resolveTapAt(sender.location(in: sender.view), forSkill: skillToAdd)
    }
    
    @IBAction func selectTapAction(_ sender: UIGestureRecognizer) {
        self.scene.selectNodeAt(sender.location(in: sender.view))
    }
    
    @IBAction func panAction(_ sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .began:
            self.scene.willStartTranslateAt(sender.location(in: sender.view!))
        case .changed:
            self.scene.translate(sender.translation(in: sender.view!))
        case .ended:
            self.scene.translate(sender.translation(in: sender.view!), save: true)
        default:
            break
        }
    }
    
    @IBAction func scaleAction(_ sender: UIPanGestureRecognizer) {
        var fill: CGFloat? = nil
        
        switch sender.state {
        case .began:
            fill = self.scene.willStartScale()
        case .changed:
            fill = self.scene.scale(sender.translation(in: sender.view!))
        case .ended:
            _ = self.scene.scale(sender.translation(in: sender.view!), save: true)
        default:
            break
        }
        
        self.showScaleSliderWithFill(fill)
    }
    
    // MARK: - Actions
    @IBAction func deleteNode(_ sender: AnyObject) {
        typealias T = ()->()
        
        self.promiseSelection(T.self, cancellable: true, options: [
            (NSLocalizedString("Delete", comment: "Delete"),.destructive,{
                return self.promiseDeleteNode()
            })
        ])
        .then { closure -> Void in
            closure()
        }
        .catch { error in
            DDLogError("Error: \(error)")
        }
    }
    
    @IBAction func saveCloud(_ sender: AnyObject) {
        // Log usage
        iRate.sharedInstance().logEvent(true)
        
        // Save cloud
        MRProgressOverlayView.show()
        firstly {
            self.promiseCaptureThumbnail()
        }
        .then { thumb -> Promise<GraphCloudEntity> in
            self.scene.thumbnail = thumb
            
            // Decide
            if let _ = self.cloudEntity {
                return DataManager.promiseUpdateEntity(GraphCloudEntity.self, model: self.scene)
            }
            else {
                return DataManager.promiseEntity(GraphCloudEntity.self, model: self.scene)
            }
        }
        .then { cloudEntity -> Void in
            self.cloudEntity = cloudEntity
            DDLogInfo("Saved Cloud:\n\(cloudEntity)")
        }
        .always{
            MRProgressOverlayView.hide()
        }
        .catch { error in
            DDLogError("Error saving cloud: \(error)")
        }
    }
    
    @IBAction func settingsAction(_ sender: AnyObject) {
        // Export
        // Delete
        typealias T = ()->()

        self.promiseSelection(T.self, cancellable: true, options: [
            (NSLocalizedString("Export", comment: "Export"),.default,{
                return self.promiseExportCloud()
            }),
            (NSLocalizedString("Delete", comment: "Delete"),.destructive,{
                return self.promiseDeleteCloud()
            })
        ])
        .then { closure -> Void in
            closure()
        }
        .catch { error in
            DDLogError("Error: \(error)")
        }
    }
    
    @IBAction func exportAction(_ sender: AnyObject) {
        _ = promiseScaleToVisible()
        .then(execute: promiseExportCloud)
        .then { closure -> Void in
            closure()
        }
        .catch { error in
            DDLogError("Error: \(error)")
        }
    }
    
    @IBAction func paletteAction(_ sender: AnyObject) {
        performSegue(withIdentifier: ShowPaletteSelectionSegueIdentifier, sender: self)
    }
    
    // MARK: - Promises
    func promiseScaleToVisible() -> Promise<Void> {
        return Promise<Void>(resolvers: { (success, failure) in
            guard let scene = self.skView.scene, let camera = scene.camera else {
                success()
                return
            }
            
            guard camera.xScale != 1.0 else {
                success()
                return
            }
            
            let scale = SKAction.scaleTo(1, duration: 0.5, delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.0)
            let center = CGPoint(x: scene.size.width / 2, y: scene.size.height / 2)
            let move = SKAction.moveTo(center, duration: 0.5, delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.0)
            let group = SKAction.group([scale,move])
            
            camera.run(group){
                self.scene.cameraSaveValues()
                success()
            }
        })
    }
    
    func promiseExportCloud() -> Promise<()->()> {
        return Promise<()->()> {
            self.scene.deselectNode()
            _ = self.promiseCaptureCloudWithSize(Defined.Cloud.ExportedDefaultSize)
            .then { image -> Void in
                self.cloudImage = image
                let activityVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)
                self.present(activityVC, animated: true, completion: nil)
            }
        }
    }

    func promiseDeleteCloud() -> Promise<()->()> {
        return firstly {
            DataManager.promiseDeleteEntity(GraphCloudEntity.self, model: self.scene)
        }
        .then { _ -> (()->()) in
            return { self.performSegue(withIdentifier: "UnwindToSelection", sender: nil) }
        }
    }
    
    func promiseCaptureThumbnail() -> Promise<UIImage> {
        return Promise<UIImage> { fulfill,reject in
            let image = self.captureCloudWithSize(Defined.Cloud.ExportedDefaultSize).RBResizeImage(Defined.Cloud.ThumbnailCaptureSize)
            let thumbnail = image.RBCenterCrop(Defined.Cloud.ThumbnailDefaultSize)
            fulfill(thumbnail)
        }
    }
    
    func promiseDeleteNode() -> Promise<()->()> {
        return Promise<()->()> {
            self.scene.deleteNode()
        }
    }
    
    // MARK: - Helpers
    func promiseCaptureCloudWithSize(_ size: CGSize) -> Promise<UIImage> {
        return Promise<UIImage>(resolvers: { (success, failure) in
            let frame = skView.frame
            let color = skView.backgroundColor
            
            // Overlay image context
            UIGraphicsBeginImageContextWithOptions(frame.size, false, UIScreen.main.scale)
            
            skView.drawHierarchy(in: CGRect(origin: CGPoint.zero, size: frame.size), afterScreenUpdates: false)
            
            let overlay = UIGraphicsGetImageFromCurrentImageContext()
            
            UIGraphicsEndImageContext()
            
            overlayImageView.isHidden = false
            overlayImageView.image = overlay
            
            // Main image export context
            skView.backgroundColor = UIColor.clear
            skView.frame = CGRect(origin: CGPoint.zero, size: size)
            
            DispatchQueue.main.async() {
                UIGraphicsBeginImageContextWithOptions(size, false, 2.0)
                
                self.skView.drawHierarchy(in: CGRect(origin: CGPoint.zero, size: size), afterScreenUpdates: true)
                
                let image = UIGraphicsGetImageFromCurrentImageContext()
                
                UIGraphicsEndImageContext()
                
                self.skView.frame = frame
                self.skView.backgroundColor = color
                self.overlayImageView.isHidden = true
                
                success(image!)
            }
        })
    }
    
    func captureCloudWithSize(_ size: CGSize) -> UIImage {
        let frame = skView.frame
        let color = skView.backgroundColor
        
        // Overlay image context
        UIGraphicsBeginImageContextWithOptions(frame.size, false, UIScreen.main.scale)
        
        skView.drawHierarchy(in: CGRect(origin: CGPoint.zero, size: frame.size), afterScreenUpdates: false)
        
        let overlay = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        overlayImageView.isHidden = false
        overlayImageView.image = overlay
        
        // Main image export context
        skView.backgroundColor = UIColor.clear
        skView.frame = CGRect(origin: CGPoint.zero, size: size)
        
        UIGraphicsBeginImageContextWithOptions(size, false, 2.0)
        
        skView.drawHierarchy(in: CGRect(origin: CGPoint.zero, size: size), afterScreenUpdates: true)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        skView.frame = frame
        skView.backgroundColor = color
        overlayImageView.isHidden = true
        
        return image!
    }
    
    func showScaleSliderWithFill(_ fill: CGFloat?) {
        guard let fill = fill else {
            self.scaleProgress.isHidden = true
            return
        }
        
        self.scaleProgress.transform = CGAffineTransform(rotationAngle: CGFloat(-M_PI_2))
        self.scaleProgress.isHidden = false
        self.scaleProgress.value = Float(fill)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else {
            return
        }
        
        switch identifier {
        case ShowPaletteSelectionSegueIdentifier:
            let paletteSelectionViewController = segue.destination as! PaletteSelectionViewController
            paletteSelectionViewController.preferredContentSize = CGSize(width: 300, height: 300)
            let popoverController = paletteSelectionViewController.popoverPresentationController
            
            _ = paletteSelectionViewController.promisePalette()
            .then { palette -> Void in
                Palette.main = palette
                self.configurePalette()
            }
            
            if popoverController != nil {
                popoverController!.delegate = self
                popoverController!.backgroundColor = UIColor.black
            }
            else {
                print("no pope")
            }
        case ShowExportViewSegueIdentifier:
            (segue.destination as? CloudExportViewController)?.image = self.cloudImage
        default:
            break
        }
    }
    
}

extension GeneratorViewController {
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .default
    }
    
}

extension GeneratorViewController: TouchDownViewDelegate {
    
    func didTouch(_ down: Bool) {
        if down {
            self.showScaleSliderWithFill(self.scene.willStartScale())
        }
    }
    
}
