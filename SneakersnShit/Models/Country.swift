//
//  Country.swift
//  SneakersnShit
//
//  Created by István Kreisz on 7/25/21.
//

import Foundation

enum Country: String, Codable, CaseIterable {
    case AT
    case BE
    case BG
    case HR
    case CY
    case CZ
    case DK
    case EE
    case FI
    case FR
    case DE
    case GR
    case HU
    case IS
    case IE
    case IT
    case LV
    case LI
    case LT
    case LU
    case MT
    case NL
    case NO
    case PL
    case PT
    case RO
    case SK
    case SI
    case ES
    case SE
    case CH
    case GB
    case US
    case USE

    var name: String {
        switch self {
        case .AT:
            return "Austria"
        case .BE:
            return "Belgium"
        case .BG:
            return "Bulgaria"
        case .HR:
            return "Croatia"
        case .CY:
            return "Republic of Cyprus"
        case .CZ:
            return "Czech Republic"
        case .DK:
            return "Denmark"
        case .EE:
            return "Estonia"
        case .FI:
            return "Finland"
        case .FR:
            return "France"
        case .DE:
            return "Germany"
        case .GR:
            return "Greece"
        case .HU:
            return "Hungary"
        case .IS:
            return "Iceland"
        case .IE:
            return "Ireland"
        case .IT:
            return "Italy"
        case .LV:
            return "Latvia"
        case .LI:
            return "Liechtenstein"
        case .LT:
            return "Lithuania"
        case .LU:
            return "Luxembourg"
        case .MT:
            return "Malta"
        case .NL:
            return "Netherlands"
        case .NO:
            return "Norway"
        case .PL:
            return "Poland"
        case .PT:
            return "Portugal"
        case .RO:
            return "Romania"
        case .SK:
            return "Slovakia"
        case .SI:
            return "Slovenia"
        case .ES:
            return "Spain"
        case .SE:
            return "Sweden"
        case .CH:
            return "Switzerland"
        case .GB:
            return "UK"
        case .US:
            return "US (mainland)"
        case .USE:
            return "US (Alaska, Hawaii)"
        }
    }

    var code: String {
        switch self {
        case .USE:
            return "US"
        default:
            return rawValue
        }
    }

    var region: String {
        switch self {
        case .AT,
             .BE,
             .BG,
             .HR,
             .CY,
             .CZ,
             .DK,
             .EE,
             .FI,
             .FR,
             .DE,
             .GR,
             .HU,
             .IS,
             .IE,
             .IT,
             .LV,
             .LI,
             .LT,
             .LU,
             .MT,
             .NL,
             .NO,
             .PL,
             .PT,
             .RO,
             .SK,
             .SI,
             .ES,
             .SE,
             .CH,
             .GB:
            return "EU"
        case .US,
             .USE:
            return "US"
        }
    }
}
