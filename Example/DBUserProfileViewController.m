//
//  DBUserProfileViewController.m
//  DBProfileViewController
//
//  Created by Devon Boyer on 2016-01-15.
//  Copyright © 2016 Devon Boyer. All rights reserved.
//

#import "DBUserProfileViewController.h"
#import "DBFollowersTableViewController.h"
#import "DBPhotosTableViewController.h"
#import "DBLikesTableViewController.h"
#import "DBUserProfileDetailView.h"

static const NSInteger DBUserProfileNumberOfContentControllers = 3;

typedef NS_ENUM(NSInteger, DBUserProfileContentControllerIndex) {
    DBUserProfileContentControllerIndexFollowers,
    DBUserProfileContentControllerIndexPhotos,
    DBUserProfileContentControllerIndexLikes
};

@interface DBUserProfileViewController () <DBProfileViewControllerDataSource, DBProfileViewControllerDelegate, DBUserProfileDetailViewDelegate>

@end

@implementation DBUserProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"DBProfileViewController";
    
    self.delegate = self;
    self.dataSource = self;

    // Register accessory views
    [self registerClass:[DBProfileAvatarView class] forAccessoryViewOfKind:DBProfileAccessoryKindAvatar];
    [self registerClass:[DBProfileCoverPhotoView class] forAccessoryViewOfKind:DBProfileAccessoryKindHeader];
    
    // Customize detail view
    DBUserProfileDetailView *detailView = [[DBUserProfileDetailView alloc] init];
    detailView.nameLabel.text = @"DBProfileViewController";
    detailView.usernameLabel.text = @"by @devboyer";
    detailView.descriptionLabel.text = @"A customizable library for creating stunning user profiles.";
    detailView.delegate = self;
    self.detailView = detailView;
        
    DBProfileAvatarView *avatarView = [self accessoryViewOfKind:DBProfileAccessoryKindAvatar];
    [avatarView setAvatarImage:[UIImage imageNamed:@"demo-avatar"] animated:NO];
    
    DBProfileCoverPhotoView *coverPhotoView = [self accessoryViewOfKind:DBProfileAccessoryKindHeader];
    [coverPhotoView setCoverPhotoImage:[UIImage imageNamed:@"demo-header"] animated:NO];
    
    // Customize layout attributes
    DBProfileHeaderViewLayoutAttributes *headerViewLayoutAttributes = [self layoutAttributesForAccessoryViewOfKind:DBProfileAccessoryKindHeader];
    
    DBProfileAvatarViewLayoutAttributes *avatarViewLayoutAttributes = [self layoutAttributesForAccessoryViewOfKind:DBProfileAccessoryKindAvatar];
    
    headerViewLayoutAttributes.headerStyle = DBProfileHeaderStyleNavigation;
    
    switch (self.style) {
        case DBUserProfileViewControllerStyle1:
            headerViewLayoutAttributes.headerStyle = DBProfileHeaderStyleDefault;
        case DBUserProfileViewControllerStyle2:
            avatarViewLayoutAttributes.avatarAlignment = DBProfileAvatarAlignmentLeft;
            avatarView.avatarStyle = DBProfileAvatarStyleRoundedRect;
            break;
        case DBUserProfileViewControllerStyle3: {
            avatarViewLayoutAttributes.avatarAlignment = DBProfileAvatarAlignmentCenter;
            avatarView.avatarStyle = DBProfileAvatarStyleRound;
            
            DBUserProfileDetailView *detailView = self.detailView;
            detailView.nameLabel.textAlignment = NSTextAlignmentCenter;
            detailView.usernameLabel.textAlignment = NSTextAlignmentCenter;
            detailView.descriptionLabel.textAlignment = NSTextAlignmentCenter;
            
            break;
        }
        default:
            break;
    }
}

#pragma mark - DBUserProfileDetailsViewDelegate

- (void)userProfileDetailView:(DBUserProfileDetailView *)detailsView didShowSupplementaryView:(UIView *)view
{
    [self beginUpdates];
    [detailsView invalidateIntrinsicContentSize];
    [self endUpdates];
}

#pragma mark - DBProfileViewControllerDataSource

- (NSUInteger)numberOfContentControllersForProfileViewController:(DBProfileViewController *)profileViewController {
    return DBUserProfileNumberOfContentControllers;
}

- (DBProfileContentController *)profileViewController:(DBProfileViewController *)profileViewController contentControllerAtIndex:(NSUInteger)controllerIndex {
    switch (controllerIndex) {
        case DBUserProfileContentControllerIndexFollowers:
            return [[DBFollowersTableViewController alloc] init];
        case DBUserProfileContentControllerIndexPhotos:
            return [[DBPhotosTableViewController alloc] init];
        case DBUserProfileContentControllerIndexLikes:
            return [[DBLikesTableViewController alloc] init];
        default:
            break;
    }
    return nil;
}

- (NSString *)profileViewController:(DBProfileViewController *)profileViewController titleForContentControllerAtIndex:(NSUInteger)controllerIndex {
    switch (controllerIndex) {
        case DBUserProfileContentControllerIndexFollowers:
            return @"Followers";
        case DBUserProfileContentControllerIndexPhotos:
            return @"Photos";
        case DBUserProfileContentControllerIndexLikes:
            return @"Likes";
        default:
            break;
    }
    return nil;
}

- (NSString *)profileViewController:(DBProfileViewController *)profileViewController subtitleForContentControllerAtIndex:(NSUInteger)controllerIndex {
    switch (controllerIndex) {
        case DBUserProfileContentControllerIndexFollowers:
            return @"20 Followers";
        case DBUserProfileContentControllerIndexPhotos:
            return @"12 Photos";
        case DBUserProfileContentControllerIndexLikes:
            return @"4 Likes";
        default:
            break;
    }
    return nil;
}

#pragma mark - DBProfileViewControllerDelegate

- (CGSize)profileViewController:(DBProfileViewController *)controller referenceSizeForAccessoryViewOfKind:(NSString *)accessoryViewKind
{
    if ([accessoryViewKind isEqualToString:DBProfileAccessoryKindAvatar]) {
        return CGSizeMake(0, 72);
    }
    else if ([accessoryViewKind isEqualToString:DBProfileAccessoryKindHeader]) {
        return CGSizeMake(0, 120);
    }
    
    return CGSizeZero;
}

- (void)profileViewController:(DBProfileViewController *)controller didLongPressAccessoryView:(__kindof DBProfileAccessoryView *)accessoryView ofKind:(NSString *)accessoryViewKind
{
    NSLog(@"Long Press");
}

- (void)profileViewController:(DBProfileViewController *)controller didTapAccessoryView:(__kindof DBProfileAccessoryView *)accessoryView ofKind:(NSString *)accessoryViewKind
{
    NSLog(@"Tap");
}

- (void)profileViewController:(DBProfileViewController *)controller willShowContentControllerAtIndex:(NSInteger)index { }

- (void)profileViewController:(DBProfileViewController *)controller didShowContentControllerAtIndex:(NSInteger)index { }

- (void)profileViewController:(DBProfileViewController *)controller didPullToRefreshContentControllerAtIndex:(NSInteger)index
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self endRefreshing];
    });
}

@end
