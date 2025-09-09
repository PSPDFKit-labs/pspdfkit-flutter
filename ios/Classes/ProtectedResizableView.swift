//
//  Copyright © 2024-2025 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

import Foundation
import PSPDFKit

/// Custom ResizableView that can be controlled externally to disable resizing for protected annotations
/// 
/// This class allows dynamic control of annotation resizing based on the `resizingEnabled` static property.
/// When `resizingEnabled` is set to false, annotations will not show resize handles and cannot be resized.
/// This is used in conjunction with annotation selection delegates to disable resizing for annotations
/// that have 'hideDelete': true in their customData.
///
/// Usage:
/// ```
/// // Disable resizing for protected annotations
/// ProtectedResizableView.resizingEnabled = false
/// 
/// // Re-enable resizing for normal annotations
/// ProtectedResizableView.resizingEnabled = true
/// ```
///
/// References:
/// - PSPDFKit ResizableView: https://www.nutrient.io/api/ios/documentation/pspdfkitui/resizableview
/// - Class Override Guide: https://www.nutrient.io/guides/ios/getting-started/overriding-classes/
@objc public class ProtectedResizableView: ResizableView{
    /// Static property to control resizing globally for all ProtectedResizableView instances
    /// Set to false to disable resizing for protected annotations, true to enable resizing
    static var resizingEnabled: Bool = true
    
    /// Override the allowResizing property to return our static control value
    public override var allowResizing: Bool {
        get {
            return ProtectedResizableView.resizingEnabled
        }
        set {
            // Do nothing - controlled by static property
            // This prevents external code from directly setting allowResizing
        }
    }
    
    public override var allowRotating: Bool {
        get {
            return ProtectedResizableView.resizingEnabled
        }
        set {
            // Do nothing - controlled by static property
            // This prevents external code from directly setting allowRotating
        }
    }
}
