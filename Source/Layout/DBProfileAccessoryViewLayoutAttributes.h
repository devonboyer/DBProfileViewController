//
//  DBProfileAccessoryViewLayoutAttributes.h
//  Pods
//
//  Created by Devon Boyer on 2016-04-07.
//
//

#import <Foundation/Foundation.h>
#import "DBProfileViewControllerConstants.h"

typedef NS_ENUM(NSInteger, DBProfileAccessorySize) {
    DBProfileAccessorySizeNormal,
    DBProfileAccessorySizeLarge,
};

typedef NS_ENUM(NSInteger, DBProfileAccessoryAlignment) {
    DBProfileAccessoryAlignmentLeft,
    DBProfileAccessoryAlignmentRight,
    DBProfileAccessoryAlignmentCenter,
};

// view model for DBProfileAccessoryView to specify customization layout
@interface DBProfileAccessoryViewLayoutAttributes : NSObject

+ (instancetype)layoutAttributesForAccessoryViewOfKind:(NSString *)accessoryKind;

@property (nonatomic, strong, readonly) NSString *representedAccessoryKind;

@property (nonatomic, assign) CGRect frame;

@property (nonatomic, assign) CGRect bounds;

@property (nonatomic, assign) CGFloat alpha;

@property (nonatomic, assign) BOOL hidden;

@property (nonatomic, assign) DBProfileAccessoryAlignment alignment;

@property (nonatomic, assign) DBProfileAccessorySize size;

@end

@interface DBProfileCoverPhotoLayoutAttributes : DBProfileAccessoryViewLayoutAttributes

+ (instancetype)layoutAttributes;

@property (nonatomic, strong, readonly) UINavigationItem *navigationItem;

@property (nonatomic, assign) DBProfileCoverPhotoOptions options;

@property (nonatomic, assign) BOOL mimicsNavigationBar;

@end