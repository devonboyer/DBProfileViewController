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
#import "DBUserProfileDetailsView.h"

static const NSInteger DBUserProfileNumberOfContentControllers = 3;

typedef NS_ENUM(NSInteger, DBUserProfileContentControllerIndex) {
    DBUserProfileContentControllerIndexFollowers,
    DBUserProfileContentControllerIndexPhotos,
    DBUserProfileContentControllerIndexLikes
};

@interface DBUserProfileViewController () <DBProfileViewControllerDataSource, DBProfileViewControllerDelegate, DBUserProfileDetailsViewDelegate>

@end

@implementation DBUserProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"DBProfileViewController";
    
    self.delegate = self;
    self.dataSource = self;
    
    // Customize profile appearance
    self.allowsPullToRefresh = YES;
    
    // Customize details view
    DBUserProfileDetailsView *detailsView = [[DBUserProfileDetailsView alloc] init];
    detailsView.nameLabel.text = @"DBProfileViewController";
    detailsView.usernameLabel.text = @"by @devboyer";
    detailsView.descriptionLabel.text = @"A customizable library for creating stunning user profiles.";
    detailsView.delegate = self;
    self.detailsView = detailsView;
    
//    DBProfileDetailsView *detailsView = (DBProfileDetailsView *)self.detailsView;
//    detailsView.nameLabel.text = @"DBProfileViewController";
//    detailsView.usernameLabel.text = @"by @devboyer";
//    detailsView.descriptionLabel.text = @"A customizable library for creating stunning user profiles.";
    
    DBProfileAvatarView *avatarView = (DBProfileAvatarView *)[self accessoryViewOfKind:DBProfileAccessoryKindAvatar];
    [avatarView setAvatarImage:[UIImage imageNamed:@"demo-avatar"] animated:NO];
    
    // Set cover photo and avatar images
    DBProfileCoverPhotoView *coverPhotoView = (DBProfileCoverPhotoView *)[self accessoryViewOfKind:DBProfileAccessoryKindCoverPhoto];
    [coverPhotoView setCoverPhotoImage:[UIImage imageNamed:@"demo-header"] animated:NO];
    
    [self setStyle:self.style];
}

- (void)setStyle:(DBUserProfileViewControllerStyle)style {
    _style = style;
    
    DBProfileAvatarView *avatarView = (DBProfileAvatarView *)[self accessoryViewOfKind:DBProfileAccessoryKindAvatar];
    
    DBProfileAvatarLayoutAttributes *avatarLayoutAttributes = (DBProfileAvatarLayoutAttributes *)[self layoutAtttributesForAccessoryViewOfKind:DBProfileAccessoryKindAvatar];
    DBProfileCoverPhotoLayoutAttributes *coverPhotoLayoutAttributes = (DBProfileCoverPhotoLayoutAttributes *)[self layoutAtttributesForAccessoryViewOfKind:DBProfileAccessoryKindCoverPhoto];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    coverPhotoLayoutAttributes.style = DBProfileCoverPhotoLayoutStyleNavigation;
    
    switch (style) {
        case DBUserProfileViewControllerStyle1:
            self.automaticallyAdjustsScrollViewInsets = YES;
            coverPhotoLayoutAttributes.style = DBProfileCoverPhotoLayoutStyleNone;
        case DBUserProfileViewControllerStyle2:
            avatarView.style = DBProfileAvatarStyleRoundedRect;
            avatarLayoutAttributes.alignment = DBProfileAvatarLayoutAlignmentLeft;
            avatarLayoutAttributes.size = DBProfileAvatarLayoutSizeNormal;
            break;
        case DBUserProfileViewControllerStyle3: {
            avatarView.style = DBProfileAvatarStyleRound;
            avatarLayoutAttributes.alignment = DBProfileAvatarLayoutAlignmentCenter;
            avatarLayoutAttributes.size = DBProfileAvatarLayoutSizeLarge;
            
            DBProfileDetailsView *detailsView = (DBProfileDetailsView *)self.detailsView;
            detailsView.nameLabel.textAlignment = NSTextAlignmentCenter;
            detailsView.usernameLabel.textAlignment = NSTextAlignmentCenter;
            detailsView.descriptionLabel.textAlignment = NSTextAlignmentCenter;
            
            break;
        }
        default:
            break;
    }
}

#pragma mark - DBUserProfileDetailsViewDelegate

- (void)userProfileDetailsView:(DBUserProfileDetailsView *)detailsView didShowSupplementaryView:(UIView *)view {
    [self beginUpdates];
    [detailsView invalidateIntrinsicContentSize];
    [self endUpdates];
}

#pragma mark - DBProfileViewControllerDataSource

- (NSUInteger)numberOfContentControllersForProfileViewController:(DBProfileViewController *)profileViewController {
    return DBUserProfileNumberOfContentControllers;
}

- (DBProfileContentController *)profileViewController:(DBProfileViewController *)profileViewController contentControllerAtIndex:(NSUInteger)index {

    switch (index) {
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

- (NSString *)profileViewController:(DBProfileViewController *)profileViewController titleForContentControllerAtIndex:(NSUInteger)index {
    switch (index) {
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

- (NSString *)profileViewController:(DBProfileViewController *)profileViewController subtitleForContentControllerAtIndex:(NSUInteger)index {
    switch (index) {
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

- (void)profileViewController:(DBProfileViewController *)profileViewController didSelectAccessoryView:(DBProfileAccessoryView *)accessoryView {
    [profileViewController deselectAccessoryView:accessoryView animated:YES];
}

- (void)profileViewController:(DBProfileViewController *)profileViewController willShowContentControllerAtIndex:(NSInteger)index { }

- (void)profileViewController:(DBProfileViewController *)profileViewController didShowContentControllerAtIndex:(NSInteger)index { }

- (void)profileViewController:(DBProfileViewController *)viewController didPullToRefreshContentControllerAtIndex:(NSInteger)index {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self endRefreshing];
    });
}

@end
