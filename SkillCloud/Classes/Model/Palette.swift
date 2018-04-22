//
//  Palette.swift
//  SkillCloud
//
//  Created by Andrzej Michnia on 29.12.2016.
//  Copyright © 2016 amichnia. All rights reserved.
//

import UIKit

protocol GraphPaletteType {
    var node: UIColor { get }
    var selection: UIColor { get }

    func color(for experience: Skill.Experience) -> UIColor
    func color(for scale: Int) -> UIColor
}

struct Palette {
    // MARK: - Properties
    let identifier: String
    var node: UIColor           = UIColor(netHex: 0x349EC2)
    var selection: UIColor      = UIColor(netHex: 0xFF8000)
    var light: UIColor          = UIColor(netHex: 0xecebe8)
    var skills: [Skill.Experience: UIColor]
    var lineWidth: CGFloat      = 10
    
    // MARK: - Pallettes
    static var `default` = Palette.all.first!
    static var main = Palette.default
    
    // MARK: - Initializers
    init(_ identifier: String, node: UIColor? = nil, selection: UIColor? = nil, skills: [Skill.Experience: UIColor] = [:]){
        self.identifier = identifier
        self.node ?= node
        self.selection ?= selection
        self.skills = skills
    }
}

extension Palette: GraphPaletteType {
    func color(for experience: Skill.Experience) -> UIColor {
        return skills[experience] ?? node
    }

    func color(for scale: Int) -> UIColor {
        switch scale {
            case 2: return color(for: .beginner)
            case 3: return color(for: .intermediate)
            default: return node
        }
    }
}

extension Palette {
    func thumbnail(for size: CGSize) -> UIImage {
        return UIImage.circle(size: size, colors: [
            node,
            color(for: .beginner),
            color(for: .intermediate),
            color(for: .professional),
            color(for: .expert)
        ])
    }
}

extension Palette {
    static var all: [Palette] {
        return [
            Palette("turquiseSimple", node: R.color.graphPaletteTurquiseSimple.nodes() , selection: R.color.graphPaletteTurquiseSimple.selection()),
            Palette("turquiseShades", node: R.color.graphPaletteTurquiseShades.nodes() , selection: R.color.graphPaletteTurquiseShades.selection(), skills: [
                Skill.Experience.beginner:     R.color.graphPaletteTurquiseShades.skill1(),
                Skill.Experience.intermediate: R.color.graphPaletteTurquiseShades.skill2(),
                Skill.Experience.professional: R.color.graphPaletteTurquiseShades.skill3(),
                Skill.Experience.expert:       R.color.graphPaletteTurquiseShades.skill4()
            ]),
            Palette("steelAndGlass", node: R.color.graphPaletteSteelAndGlass.nodes() , selection: R.color.graphPaletteSteelAndGlass.selection(), skills: [
                Skill.Experience.beginner:     R.color.graphPaletteSteelAndGlass.nodes(),
                Skill.Experience.intermediate: R.color.graphPaletteSteelAndGlass.skillsSmall(),
                Skill.Experience.professional: R.color.graphPaletteSteelAndGlass.skillsMedium(),
                Skill.Experience.expert:       R.color.graphPaletteSteelAndGlass.skillsBig()
            ]),
            Palette("autumntRed", node: R.color.graphPaletteAutumnRed.nodes() , selection: R.color.graphPaletteAutumnRed.selection(), skills: [
                Skill.Experience.beginner:     R.color.graphPaletteAutumnRed.nodes(),
                Skill.Experience.intermediate: R.color.graphPaletteAutumnRed.skill1(),
                Skill.Experience.professional: R.color.graphPaletteAutumnRed.skill2(),
                Skill.Experience.expert:       R.color.graphPaletteAutumnRed.skill3()
            ]),
            Palette("grayGreenForest", node: R.color.graphPaletteGrayGreenForest.nodes() , selection: R.color.graphPaletteGrayGreenForest.selection(), skills: [
                Skill.Experience.beginner:     R.color.graphPaletteGrayGreenForest.skill1(),
                Skill.Experience.intermediate: R.color.graphPaletteGrayGreenForest.skill2(),
                Skill.Experience.professional: R.color.graphPaletteGrayGreenForest.skill3(),
                Skill.Experience.expert:       R.color.graphPaletteGrayGreenForest.skill4()
            ]),
            Palette("greens", node: R.color.graphPaletteGreens.nodes() , selection: R.color.graphPaletteGreens.selection(), skills: [
                Skill.Experience.beginner:     R.color.graphPaletteGreens.skill1(),
                Skill.Experience.intermediate: R.color.graphPaletteGreens.skill2(),
                Skill.Experience.professional: R.color.graphPaletteGreens.skill3(),
                Skill.Experience.expert:       R.color.graphPaletteGreens.skill4()
            ]),
            Palette("pastelWet", node: R.color.graphPalettePastelWet.nodes() , selection: R.color.graphPalettePastelWet.selection(), skills: [
                Skill.Experience.beginner:     R.color.graphPalettePastelWet.skill1(),
                Skill.Experience.intermediate: R.color.graphPalettePastelWet.skill2(),
                Skill.Experience.professional: R.color.graphPalettePastelWet.skill3(),
                Skill.Experience.expert:       R.color.graphPalettePastelWet.skill4()
            ]),
            Palette("lavander", node: R.color.graphPaletteLavander.nodes() , selection: R.color.graphPaletteLavander.selection(), skills: [
                Skill.Experience.beginner:     R.color.graphPaletteLavander.nodes(),
                Skill.Experience.intermediate: R.color.graphPaletteLavander.skill1(),
                Skill.Experience.professional: R.color.graphPaletteLavander.skill2(),
                Skill.Experience.expert:       R.color.graphPaletteLavander.skill3()
            ]),
            Palette("grayShades", node: R.color.graphPaletteGrayShades.nodes() , selection: R.color.graphPaletteGrayShades.selection(), skills: [
                Skill.Experience.beginner:     R.color.graphPaletteGrayShades.skill1(),
                Skill.Experience.intermediate: R.color.graphPaletteGrayShades.skill2(),
                Skill.Experience.professional: R.color.graphPaletteGrayShades.skill3(),
                Skill.Experience.expert:       R.color.graphPaletteGrayShades.skill4()
            ])
        ]
    }

    static func palette(with identifier: String) -> Palette {
        return all.first(where: { $0.identifier == identifier }) ?? Palette.default
    }
}
