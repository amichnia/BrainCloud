//
//  PossiblePlaceView.swift
//  Brain Cloud
//
//  Created by Andrzej Michnia on 17/03/16.
//  Copyright © 2016 amichnia. All rights reserved.
//

import UIKit

class PossiblePlaceView: UIView {

    var place : PossiblePlace!
    var canvas : CanvasView!
    
    func placeOnCanvas(canvas: CanvasView, possiblePlace: PossiblePlace) {
        self.place = possiblePlace
        self.canvas = canvas
        self.frame = CGRect(origin: canvas[self.place.position], size: canvas[self.place.size])
        self.canvas.addSubview(self)
    }
    
}
