#if os(iOS) || os(visionOS)

import UIKit

public typealias PlatformFont = UIFont
public typealias PlatformFontDescriptor = UIFontDescriptor

#elseif os(macOS)

import AppKit

public typealias PlatformFont = NSFont
public typealias PlatformFontDescriptor = NSFontDescriptor

#endif
