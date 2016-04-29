//
//  DBProfileLayoutAttributesProvider.h
//  Pods
//
//  Created by Devon Boyer on 2016-04-28.
//
//

#import <Foundation/Foundation.h>

@class DBProfileAccessoryViewLayoutAttributes;

// Handles all layout attribute configuration and manages the array of layout attributes
// This class will manage scroll observering and invalidating based on scrolling etc.
@interface DBProfileLayoutAttributesProvider : NSObject

@property (nonatomic) NSDictionary<NSString *, DBProfileAccessoryViewLayoutAttributes *> *layoutAttributes;

- (__kindof DBProfileAccessoryViewLayoutAttributes *)layoutAttributesForAccessoryViewOfKind:(NSString *)accessoryViewKind;
- (void)invalidateLayoutAttributesForAccessoryViewOfKind:(NSString *)accessoryViewKind;
- (BOOL)shouldInvalidateLayoutAttributesForAccessoryViewOfKind:(NSString *)accessoryViewKind forBoundsChange:(CGRect)newBounds;

@end
