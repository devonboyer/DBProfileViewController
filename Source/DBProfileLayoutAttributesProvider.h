//
//  DBProfileLayoutAttributesProvider.h
//  Pods
//
//  Created by Devon Boyer on 2016-04-28.
//
//

#import <Foundation/Foundation.h>

#import <DBProfileViewController/DBProfileViewControllerDelegate.h>

@class DBProfileViewController;
@class DBProfileLayoutAttributesProvider;
@class DBProfileAccessoryViewLayoutAttributes;

@protocol DBProfileLayoutAttributesProviderDelegate <DBProfileViewControllerDelegate>

- (CGSize)profileViewController:(DBProfileViewController *)controller provider:(DBProfileLayoutAttributesProvider *)provider referenceSizeForAccessoryViewOfKind:(NSString *)accessoryViewKind;

@end

@interface DBProfileLayoutAttributesProvider : NSObject

+ (Class)layoutAttributesClassForAccessoryViewOfKind:(NSString *)accessoryViewKind;

@property (nonatomic, weak, readonly) DBProfileViewController *profileViewController;

@property (nonatomic) CGSize headerReferenceSize;

@property (nonatomic) CGSize avatarReferenceSize;

- (__kindof DBProfileAccessoryViewLayoutAttributes *)layoutAttributesForAccessoryViewOfKind:(NSString *)accessoryViewKind;

- (BOOL)shouldInvalidateLayoutAttributesForAccessoryViewOfKind:(NSString *)accessoryViewKind forBoundsChange:(CGRect)newBounds;

- (void)invalidateLayoutAttributesForAccessoryViewOfKind:(NSString *)accessoryViewKind;

- (void)invalidateAllLayoutAttributes;

@end

@interface DBProfileLayoutAttributesProvider (InstallingConstraints)

- (BOOL)shouldInstallConstraintsForAccessoryViewOfKind:(NSString *)accessoryViewKind;

- (void)installConstraintsForAccessoryViewOfKind:(NSString *)accessoryViewKind;

- (void)uninstallConstraintsForAccessoryViewOfKind:(NSString *)accessoryViewKind;

@end


