//
//  HapticsManager.swift
//  Stocks-demo
//
//  Created by Евгений Романов on 28.10.2022.
//

import Foundation
import UIKit

/// Object to manage haptics
final class HapticsManager {
    
    /// Singleton
    static let shared = HapticsManager()
    
    /// Private constructor
    private init() {}
    
    //MARK: Public
    
    /// Vibrate lightly for selection
    public func vibrateForSelection() {
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }
    
    /// Play haptic for given type interaction
    /// - Parameter type: Type to vibrate for 
    public func vibrate(for type: UINotificationFeedbackGenerator.FeedbackType){
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(type)
    }
}
