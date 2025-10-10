#import <Foundation/Foundation.h>

#if __has_attribute(swift_private)
#define AC_SWIFT_PRIVATE __attribute__((swift_private))
#else
#define AC_SWIFT_PRIVATE
#endif

/// The "array-data-type" asset catalog image resource.
static NSString * const ACImageNameArrayDataType AC_SWIFT_PRIVATE = @"array-data-type";

/// The "boolean-data-type" asset catalog image resource.
static NSString * const ACImageNameBooleanDataType AC_SWIFT_PRIVATE = @"boolean-data-type";

/// The "null-data-type" asset catalog image resource.
static NSString * const ACImageNameNullDataType AC_SWIFT_PRIVATE = @"null-data-type";

/// The "number-data-type" asset catalog image resource.
static NSString * const ACImageNameNumberDataType AC_SWIFT_PRIVATE = @"number-data-type";

/// The "object-data-type" asset catalog image resource.
static NSString * const ACImageNameObjectDataType AC_SWIFT_PRIVATE = @"object-data-type";

/// The "string-data-type" asset catalog image resource.
static NSString * const ACImageNameStringDataType AC_SWIFT_PRIVATE = @"string-data-type";

#undef AC_SWIFT_PRIVATE
