//
//  ModelClasses.swift
//  Licenta
//
//  Created by Fariseu, Teodora on 5/26/23.
//

import Foundation
import UIKit

//clasele posibile prezise de model
public enum ModelClass: String, SelectableFilter, Identifiable {
    var displayName: String {
        rawValue
    }
    
    public var id: String {
        self.rawValue
    }
    
    case background
    case wall
    case building
    case sky
    case floor
    case tree
    case ceiling
    case road
    case bed
    case window
    case grass
    case cabinet
    case sidewalk
    case person
    case ground
    case door
    case table
    case mountain
    case plant
    case curtain
    case chair
    case car
    case water
    case painting
    case sofa
    case shelf
    case house
    case sea
    case mirror
    case carpet
    case field
    case armchair
    case seat
    case fence
    case desk
    case rock
    case closet
    case lamp
    case bathtub
    case railing
    case cushion
    case pedestal
    case box
    case pillar
    case signboard
    case bureau
    case counter
    case sand
    case sink
    case skyscraper
    case fireplace
    case refrigerator
    case grandstand
    case path
    case stairs
    case runway
    case displayCase = "display case"
    case poolTable = "pool table"
    case pillow
    case screenDoor = "screen door"
    case stairway
    case river
    case bridge
    case bookcase
    case blind
    case coffeeTable = "coffee table"
    case toilet
    case flower
    case book
    case hill
    case bench
    case countertop
    case stove
    case palm
    case kitchenIsland = "kitchen island"
    case computer
    case swivelChair = "swivel chair"
    case boat
    case bar
    case arcadeMachine = "arcade machine"
    case hut
    case bus
    case towel
    case light
    case truck
    case tower
    case chandelier
    case sunblind
    case streetlight
    case booth
    case television
    case airplane
    case dirtTrack = "dirt track"
    case clothes
    case pole
    case land
    case bannister
    case escalator
    case ottoman
    case bottle
    case buffet
    case poster
    case stage
    case van
    case ship
    case fountain
    case conveyerBelt = "conveyer belt"
    case canopy
    case washer
    case toy
    case swimmingPool = "swimming pool"
    case stool
    case barrel
    case basket
    case waterfall
    case tent
    case bag
    case motorbike
    case cradle
    case oven
    case ball
    case food
    case stair
    case tank
    case brand
    case microwave
    case flowerpot
    case animal
    case bicycle
    case lake
    case dishwasher
    case projectionScreen = "projection screen"
    case blanket
    case sculpture
    case hood
    case sconce
    case vase
    case trafficLight = "traffic light"
    case tray
    case garbageCan = "garbage can"
    case fan
    case pier
    case crtScreen = "crt screen"
    case plate
    case monitor
    case bulletinBoard = "bulletin board"
    case shower
    case radiator
    case glass
    case clock
    case flag
    
    func equals(index: UInt8) -> Bool {
        ModelClass.modelClass(with: index) == self
    }
    
    //label-ul numeric al clasei
    var orderNumber: Int {
        ModelClass.allCases.firstIndex(of: self) ?? 0
    }
    
    //transformarea din label/numar de ordine in clasa
    static func modelClass(with index: UInt8) -> ModelClass {
        ModelClass.allCases[Int(index)]
    }
    
    //culoarea cu care clasa e afisata in UI
    var color: UIColor {
        UIColor(named: self.rawValue.replacingOccurrences(of: " ", with: "_")) ?? .black
    }
}
