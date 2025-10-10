import Foundation
#if canImport(AppKit)
import AppKit
#endif
#if canImport(UIKit)
import UIKit
#endif
#if canImport(SwiftUI)
import SwiftUI
#endif
#if canImport(DeveloperToolsSupport)
import DeveloperToolsSupport
#endif

#if SWIFT_PACKAGE
private let resourceBundle = Foundation.Bundle.module
#else
private class ResourceBundleClass {}
private let resourceBundle = Foundation.Bundle(for: ResourceBundleClass.self)
#endif

// MARK: - Color Symbols -

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension DeveloperToolsSupport.ColorResource {

}

// MARK: - Image Symbols -

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension DeveloperToolsSupport.ImageResource {

    /// The "array-data-type" asset catalog image resource.
    static let arrayDataType = DeveloperToolsSupport.ImageResource(name: "array-data-type", bundle: resourceBundle)

    /// The "boolean-data-type" asset catalog image resource.
    static let booleanDataType = DeveloperToolsSupport.ImageResource(name: "boolean-data-type", bundle: resourceBundle)

    /// The "null-data-type" asset catalog image resource.
    static let nullDataType = DeveloperToolsSupport.ImageResource(name: "null-data-type", bundle: resourceBundle)

    /// The "number-data-type" asset catalog image resource.
    static let numberDataType = DeveloperToolsSupport.ImageResource(name: "number-data-type", bundle: resourceBundle)

    /// The "object-data-type" asset catalog image resource.
    static let objectDataType = DeveloperToolsSupport.ImageResource(name: "object-data-type", bundle: resourceBundle)

    /// The "string-data-type" asset catalog image resource.
    static let stringDataType = DeveloperToolsSupport.ImageResource(name: "string-data-type", bundle: resourceBundle)

}

// MARK: - Color Symbol Extensions -

#if canImport(AppKit)
@available(macOS 14.0, *)
@available(macCatalyst, unavailable)
extension AppKit.NSColor {

}
#endif

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIColor {

}
#endif

#if canImport(SwiftUI)
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.Color {

}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.ShapeStyle where Self == SwiftUI.Color {

}
#endif

// MARK: - Image Symbol Extensions -

#if canImport(AppKit)
@available(macOS 14.0, *)
@available(macCatalyst, unavailable)
extension AppKit.NSImage {

    /// The "array-data-type" asset catalog image.
    static var arrayDataType: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .arrayDataType)
#else
        .init()
#endif
    }

    /// The "boolean-data-type" asset catalog image.
    static var booleanDataType: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .booleanDataType)
#else
        .init()
#endif
    }

    /// The "null-data-type" asset catalog image.
    static var nullDataType: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .nullDataType)
#else
        .init()
#endif
    }

    /// The "number-data-type" asset catalog image.
    static var numberDataType: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .numberDataType)
#else
        .init()
#endif
    }

    /// The "object-data-type" asset catalog image.
    static var objectDataType: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .objectDataType)
#else
        .init()
#endif
    }

    /// The "string-data-type" asset catalog image.
    static var stringDataType: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .stringDataType)
#else
        .init()
#endif
    }

}
#endif

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIImage {

    /// The "array-data-type" asset catalog image.
    static var arrayDataType: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .arrayDataType)
#else
        .init()
#endif
    }

    /// The "boolean-data-type" asset catalog image.
    static var booleanDataType: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .booleanDataType)
#else
        .init()
#endif
    }

    /// The "null-data-type" asset catalog image.
    static var nullDataType: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .nullDataType)
#else
        .init()
#endif
    }

    /// The "number-data-type" asset catalog image.
    static var numberDataType: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .numberDataType)
#else
        .init()
#endif
    }

    /// The "object-data-type" asset catalog image.
    static var objectDataType: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .objectDataType)
#else
        .init()
#endif
    }

    /// The "string-data-type" asset catalog image.
    static var stringDataType: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .stringDataType)
#else
        .init()
#endif
    }

}
#endif

// MARK: - Thinnable Asset Support -

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
@available(watchOS, unavailable)
extension DeveloperToolsSupport.ColorResource {

    private init?(thinnableName: Swift.String, bundle: Foundation.Bundle) {
#if canImport(AppKit) && os(macOS)
        if AppKit.NSColor(named: NSColor.Name(thinnableName), bundle: bundle) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#elseif canImport(UIKit) && !os(watchOS)
        if UIKit.UIColor(named: thinnableName, in: bundle, compatibleWith: nil) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIColor {

    private convenience init?(thinnableResource: DeveloperToolsSupport.ColorResource?) {
#if !os(watchOS)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

#if canImport(SwiftUI)
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.Color {

    private init?(thinnableResource: DeveloperToolsSupport.ColorResource?) {
        if let resource = thinnableResource {
            self.init(resource)
        } else {
            return nil
        }
    }

}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.ShapeStyle where Self == SwiftUI.Color {

    private init?(thinnableResource: DeveloperToolsSupport.ColorResource?) {
        if let resource = thinnableResource {
            self.init(resource)
        } else {
            return nil
        }
    }

}
#endif

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
@available(watchOS, unavailable)
extension DeveloperToolsSupport.ImageResource {

    private init?(thinnableName: Swift.String, bundle: Foundation.Bundle) {
#if canImport(AppKit) && os(macOS)
        if bundle.image(forResource: NSImage.Name(thinnableName)) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#elseif canImport(UIKit) && !os(watchOS)
        if UIKit.UIImage(named: thinnableName, in: bundle, compatibleWith: nil) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}

#if canImport(AppKit)
@available(macOS 14.0, *)
@available(macCatalyst, unavailable)
extension AppKit.NSImage {

    private convenience init?(thinnableResource: DeveloperToolsSupport.ImageResource?) {
#if !targetEnvironment(macCatalyst)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIImage {

    private convenience init?(thinnableResource: DeveloperToolsSupport.ImageResource?) {
#if !os(watchOS)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

