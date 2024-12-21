//
//  EffortRatingViewApp.swift
//  EffortRatingView
//
//  Created by Sagar Dagdu on 21/12/24.
//

import SwiftUI

@main
struct EffortRatingViewApp: App {
    var body: some Scene {
        WindowGroup {
            EffortRatingView(title: "How hard did you try?", onEffortSelected: { intensity, level in
                print("Selected \(intensity.rawValue) at level \(level)")
            })
        }
    }
}
