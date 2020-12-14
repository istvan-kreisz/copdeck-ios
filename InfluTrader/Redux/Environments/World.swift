//
//  World.swift
//  InfluTrader
//
//  Created by István Kreisz on 12/13/20.
//

import Foundation
import Combine

class GithubService {}

class TrendsService {
    var publisher = CurrentValueSubject<Void, Error>(())
}

class CalendarService {
    var publisher = CurrentValueSubject<Void, Error>(())
}

class Trends {
    let service = TrendsService()
}

class Calendar {
    let service = CalendarService()
}

class World {
    var service = GithubService()
    
    lazy var trends = Trends()
    lazy var calendar = Calendar()
}

