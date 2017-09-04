//
//  PaletteSelectionViewController.swift
//  SkillCloud
//
//  Created by Andrzej Michnia on 30.12.2016.
//  Copyright © 2016 amichnia. All rights reserved.
//

import UIKit
import PromiseKit

class PaletteSelectionViewController: UIViewController {
    // MARK: - Outlets
    @IBOutlet var paletteButtons: [UIButton]!
    
    // MARK: - Properties
    private var complete: ((Palette) -> Void)?
    
    // MARK: - Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        for i in 0..<paletteButtons.count {
            let button = paletteButtons[i]
            
            if i < Palette.all.count {
                button.isHidden = false
                let image = Palette.all[i].thumbnail(for: CGSize(width: 44, height: 44))
                button.setImage(image, for: .normal)
            }
            else {
                button.isHidden = true
            }
        }
    }
    
    // MARK: - Actions
    @IBAction func paletteChosen(_ sender: UIButton) {
        if let index = paletteButtons.index(of: sender) {
            let palette = Palette.all[index]
            Palette.main = palette
            complete?(palette)
        }
        
        presentingViewController?.dismiss(animated: true)
    }
    
    // MARK: - Public
    @discardableResult
    func promisePalette() -> Promise<Palette> {
        return Promise<Palette> { success,_ in
            self.complete = success
        }
    }
}
