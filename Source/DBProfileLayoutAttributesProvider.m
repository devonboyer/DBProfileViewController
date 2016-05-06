//
//  DBProfileLayoutAttributesProvider.m
//  Pods
//
//  Created by Devon Boyer on 2016-04-28.
//
//

#import "DBProfileLayoutAttributesProvider.h"
#import "DBProfileViewController.h"
#import "DBProfileAccessoryViewLayoutAttributes.h"
#import "DBProfileHeaderViewLayoutAttributes.h"
#import "DBProfileAvatarViewLayoutAttributes.h"

@interface DBProfileLayoutAttributesProvider ()

@property (nonatomic) NSMutableDictionary<NSString *, DBProfileAccessoryViewLayoutAttributes *> *layoutAttributesMap;

@property (nonatomic, weak) id<DBProfileLayoutAttributesProviderDelegate> providerDelegate;

@end

@implementation DBProfileLayoutAttributesProvider

+ (Class)layoutAttributesClassForAccessoryViewOfKind:(NSString *)accessoryViewKind {
    if ([accessoryViewKind isEqualToString:DBProfileAccessoryKindHeader]) {
        return [DBProfileHeaderViewLayoutAttributes class];
    }
    else if ([accessoryViewKind isEqualToString:DBProfileAccessoryKindAvatar]) {
        return [DBProfileAvatarViewLayoutAttributes class];
    }
    
    return [DBProfileAccessoryViewLayoutAttributes class];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        // Defaults
        self.headerReferenceSize = CGSizeMake(0, CGRectGetHeight([UIScreen mainScreen].bounds) * 0.18);
        self.avatarReferenceSize = CGSizeMake(0, 72);
    }
    return self;
}

- (id<DBProfileLayoutAttributesProviderDelegate>)providerDelegate {
    if ([self.profileViewController.delegate conformsToProtocol:@protocol(DBProfileLayoutAttributesProviderDelegate)]) {
        return (id<DBProfileLayoutAttributesProviderDelegate>)self.profileViewController.delegate;
    }
    return nil;
}

- (DBProfileAccessoryViewLayoutAttributes *)layoutAttributesForAccessoryViewOfKind:(NSString *)accessoryViewKind {
    
    DBProfileAccessoryViewLayoutAttributes *layoutAttributes = self.layoutAttributesMap[accessoryViewKind];
        
    return layoutAttributes;
}

- (void)configureLayoutAttributes:(__kindof DBProfileAccessoryViewLayoutAttributes *)layoutAttributes forAccessoryViewOfKind:(NSString *)accessoryViewKind {
    
    DBProfileAccessoryView *accessoryView = [self.profileViewController accessoryViewOfKind:accessoryViewKind];
    layoutAttributes.frame = accessoryView.frame;
    layoutAttributes.bounds = accessoryView.bounds;
    layoutAttributes.size = accessoryView.frame.size;
    layoutAttributes.center = accessoryView.center;
    layoutAttributes.hidden = accessoryView.hidden;
    layoutAttributes.alpha = accessoryView.alpha;
    layoutAttributes.transform = accessoryView.transform;
    
    if (accessoryViewKind == DBProfileAccessoryKindAvatar) {
        [self configureHeaderViewLayoutAttributes:layoutAttributes];
    }
    else if (accessoryViewKind == DBProfileAccessoryKindHeader) {
        [self configureAvatarViewLayoutAttributes:layoutAttributes];
    }
    else {
        // unsupported or custom accessory view kind
    }
}

- (void)configureHeaderViewLayoutAttributes:(DBProfileHeaderViewLayoutAttributes *)layoutAttributes {
    
    // Configure constraint-based layout attributes
    if (layoutAttributes.hasInstalledConstraints) {
        
        layoutAttributes.navigationConstraint.constant = DBProfileViewControllerNavigationBarHeightForTraitCollection(self.profileViewController.traitCollection);
        
        switch (layoutAttributes.headerStyle) {
            case DBProfileHeaderStyleNavigation:
                [NSLayoutConstraint activateConstraints:@[layoutAttributes.navigationConstraint, layoutAttributes.topSuperviewConstraint]];
                [NSLayoutConstraint deactivateConstraints:@[layoutAttributes.topLayoutGuideConstraint]];
                break;
            default:
                [NSLayoutConstraint activateConstraints:@[layoutAttributes.topLayoutGuideConstraint]];
                [NSLayoutConstraint deactivateConstraints:@[layoutAttributes.navigationConstraint, layoutAttributes.topSuperviewConstraint]];
                break;
        }
    }
}

- (void)configureAvatarViewLayoutAttributes:(DBProfileAvatarViewLayoutAttributes *)layoutAttributes {
    DBProfileHeaderViewLayoutAttributes *headerViewLayoutAttributes = [self layoutAttributesForAccessoryViewOfKind:DBProfileAccessoryKindHeader];
    
    // Configure constraint-based layout attributes
    if (layoutAttributes.hasInstalledConstraints) {
        
        switch (layoutAttributes.avatarAlignment) {
            case DBProfileAvatarAlignmentLeft:
                [NSLayoutConstraint activateConstraints:@[layoutAttributes.leftConstraint]];
                [NSLayoutConstraint deactivateConstraints:@[layoutAttributes.rightConstraint, layoutAttributes.centerXConstraint]];
                break;
            case DBProfileAvatarAlignmentRight:
                [NSLayoutConstraint activateConstraints:@[layoutAttributes.rightConstraint]];
                [NSLayoutConstraint deactivateConstraints:@[layoutAttributes.leftConstraint, layoutAttributes.centerXConstraint]];
                break;
            case DBProfileAvatarAlignmentCenter:
                [NSLayoutConstraint activateConstraints:@[layoutAttributes.centerXConstraint]];
                [NSLayoutConstraint deactivateConstraints:@[layoutAttributes.leftConstraint, layoutAttributes.rightConstraint]];
                break;
            default:
                break;
        }
        
        CGSize referenceSize = [self referenceSizeForAccessoryViewOfKind:DBProfileAccessoryKindAvatar];
        
        layoutAttributes.widthConstraint.constant = MAX(referenceSize.width, referenceSize.height);
        layoutAttributes.leftConstraint.constant = layoutAttributes.edgeInsets.left - layoutAttributes.edgeInsets.right;
        layoutAttributes.rightConstraint.constant = -(layoutAttributes.edgeInsets.left - layoutAttributes.edgeInsets.right);
        layoutAttributes.topConstraint.constant = layoutAttributes.edgeInsets.top - layoutAttributes.edgeInsets.bottom;
    }
}

- (BOOL)shouldInvalidateLayoutAttributesForAccessoryViewOfKind:(NSString *)accessoryViewKind forBoundsChange:(CGRect)newBounds {
    return accessoryViewKind == DBProfileAccessoryKindAvatar || accessoryViewKind == DBProfileAccessoryKindHeader;
}

- (void)invalidateLayoutAttributesForAccessoryViewOfKind:(NSString *)accessoryViewKind {
    DBProfileAccessoryViewLayoutAttributes *layoutAttributes = [self layoutAttributesForAccessoryViewOfKind:accessoryViewKind];
    
    [self configureLayoutAttributes:layoutAttributes
             forAccessoryViewOfKind:accessoryViewKind];
}

- (void)invalidateAllLayoutAttributes {
    [[self.layoutAttributesMap allKeys] enumerateObjectsUsingBlock:^(NSString * _Nonnull kind, NSUInteger idx, BOOL * _Nonnull stop) {
        [self invalidateLayoutAttributesForAccessoryViewOfKind:kind];
    }];
}

#pragma mark - Helpers

- (CGSize)referenceSizeForAccessoryViewOfKind:(NSString *)accessoryViewKind {
    CGSize referenceSize;
    
    if (accessoryViewKind == DBProfileAccessoryKindAvatar) {
        referenceSize = self.avatarReferenceSize;
    }
    else if (accessoryViewKind == DBProfileAccessoryKindHeader) {
        referenceSize = self.headerReferenceSize;
    }
    
    if ([self.providerDelegate respondsToSelector:@selector(profileViewController:provider:referenceSizeForAccessoryViewOfKind:)]) {
        [self.providerDelegate profileViewController:self.profileViewController provider:self referenceSizeForAccessoryViewOfKind:accessoryViewKind];
    }
    
    return referenceSize;
}

@end

@implementation DBProfileLayoutAttributesProvider (InstallingConstraints)

- (BOOL)shouldInstallConstraintsForAccessoryViewOfKind:(NSString *)accessoryViewKind {
    return YES;
}

- (void)installConstraintsForAccessoryViewOfKind:(NSString *)accessoryViewKind {
    
    DBProfileAccessoryView *accessoryView = [self.profileViewController accessoryViewOfKind:accessoryViewKind];

    if (accessoryViewKind == DBProfileAccessoryKindAvatar) {
        [self installConstraintsForAvatarView:accessoryView];
    }
    else if (accessoryViewKind == DBProfileAccessoryKindHeader) {
        [self installConstraintsForHeaderView:accessoryView];
    }
}

- (void)uninstallConstraintsForAccessoryViewOfKind:(NSString *)accessoryViewKind {
    
}

- (void)installConstraintsForHeaderView:(DBProfileAccessoryView *)headerView {
    
}

- (void)installConstraintsForAvatarView:(DBProfileAccessoryView *)avatarView {
    
}

@end
