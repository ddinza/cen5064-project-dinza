//
//  MoonPhaseService.swift
//  HookIt
//

import Foundation

struct MoonPhaseService {

    static func currentPhase(
        for date: Date = Date()
    ) -> String {
        let referenceDateComponents = DateComponents(
            calendar: Calendar(identifier: .gregorian),
            timeZone: TimeZone(secondsFromGMT: 0),
            year: 2000,
            month: 1,
            day: 6,
            hour: 18,
            minute: 14
        )

        guard let referenceDate =
                referenceDateComponents.date else {
            return "Unknown"
        }

        let lunarCycle = 29.53058867

        let daysSinceReference =
            date.timeIntervalSince(referenceDate)
            / 86400

        var moonAge =
            daysSinceReference
            .truncatingRemainder(
                dividingBy: lunarCycle
            )

        if moonAge < 0 {
            moonAge += lunarCycle
        }

        switch moonAge {
        case 0..<1.84566:
            return "New Moon"

        case 1.84566..<5.53699:
            return "Waxing Crescent"

        case 5.53699..<9.22831:
            return "First Quarter"

        case 9.22831..<12.91963:
            return "Waxing Gibbous"

        case 12.91963..<16.61096:
            return "Full Moon"

        case 16.61096..<20.30228:
            return "Waning Gibbous"

        case 20.30228..<23.99361:
            return "Last Quarter"

        case 23.99361..<27.68493:
            return "Waning Crescent"

        default:
            return "New Moon"
        }
    }

    static func currentPhaseIcon(
        for date: Date = Date()
    ) -> String {
        switch currentPhase(for: date) {
        case "New Moon":
            return "moonphase.new.moon"

        case "Waxing Crescent":
            return "moonphase.waxing.crescent"

        case "First Quarter":
            return "moonphase.first.quarter"

        case "Waxing Gibbous":
            return "moonphase.waxing.gibbous"

        case "Full Moon":
            return "moonphase.full.moon"

        case "Waning Gibbous":
            return "moonphase.waning.gibbous"

        case "Last Quarter":
            return "moonphase.last.quarter"

        case "Waning Crescent":
            return "moonphase.waning.crescent"

        default:
            return "moon.fill"
        }
    }
}
