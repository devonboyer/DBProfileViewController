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

static const NSInteger DBUserProfileNumberOfContentControllers = 3;

typedef NS_ENUM(NSInteger, DBUserProfileContentControllerIndex) {
    DBUserProfileContentControllerIndexFollowers,
    DBUserProfileContentControllerIndexPhotos,
    DBUserProfileContentControllerIndexLikes
};

@interface DBUserProfileViewController () <DBProfileViewControllerDelegate, DBProfileViewControllerDataSource>

@end

@implementation DBUserProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"DBProfileViewController";
    
    self.delegate = self;
    self.dataSource = self;
    
    // Customize profile appearance
    self.coverPhotoOptions = DBProfileCoverPhotoOptionStretch;
    self.avatarInset = UIEdgeInsetsMake(0, 15, DBProfileViewControllerAvatarSizeNormal/2.0 - 10, 0);
    self.avatarView.borderWidth = 4;
    self.allowsPullToRefresh = YES;
    
    // Customize details view
    DBProfileDetailsView *detailsView = (DBProfileDetailsView *)self.detailsView;
    detailsView.nameLabel.text = @"DBProfileViewController";
    detailsView.usernameLabel.text = @"by @devboyer";
    detailsView.descriptionLabel.text = @"A customizable library for creating stunning user profiles.";
    detailsView.contentInset = UIEdgeInsetsMake(60, 15, 15, 15);
    
    // Set cover photo and avatar images
    [self setAvatarImage:[UIImage imageNamed:@"demo-avatar"] animated:NO];
    [self setCoverPhotoImage:[UIImage imageNamed:@"demo-header"] animated:NO];
    [self setStyle:self.style];
}

- (void)setStyle:(DBUserProfileViewControllerStyle)style {
    _style = style;
    
    DBProfileDetailsView *detailsView = (DBProfileDetailsView *)self.detailsView;

    self.automaticallyAdjustsScrollViewInsets = NO;
    self.coverPhotoMimicsNavigationBar = YES;
    
    switch (style) {
        case DBUserProfileViewControllerStyle1:
            self.coverPhotoScrollAnimationStyle = DBProfileCoverPhotoScrollAnimationStyleNone;
            self.automaticallyAdjustsScrollViewInsets = YES;
            self.coverPhotoMimicsNavigationBar = NO;
        case DBUserProfileViewControllerStyle2:
            self.avatarView.style = DBProfileAvatarStyleRoundedRect;
            self.avatarSize = DBProfileAvatarSizeNormal;
            self.avatarAlignment = DBProfileAvatarAlignmentLeft;
            self.avatarView.borderWidth = 4;
            break;
        case DBUserProfileViewControllerStyle3:
            self.avatarView.style = DBProfileAvatarStyleRound;
            self.avatarSize = DBProfileAvatarSizeLarge;
            self.avatarAlignment = DBProfileAvatarAlignmentCenter;
            
            detailsView.nameLabel.textAlignment = NSTextAlignmentCenter;
            detailsView.usernameLabel.textAlignment = NSTextAlignmentCenter;
            detailsView.descriptionLabel.textAlignment = NSTextAlignmentCenter;
            break;
        default:
            break;
    }
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

- (void)profileViewController:(DBProfileViewController *)profileViewController didSelectCoverPhotoView:(DBProfileCoverPhotoView *)coverPhotoView {
    [profileViewController deselectCoverPhotoViewAnimated:YES];
}

- (void)profileViewController:(DBProfileViewController *)profileViewController didSelectAvatarView:(DBProfileAvatarView *)avatarView {
    [profileViewController deselectAvatarViewAnimated:YES];
}

- (void)profileViewController:(DBProfileViewController *)viewController didSelectContentControllerAtIndex:(NSInteger)index { }

- (void)profileViewController:(DBProfileViewController *)viewController didPullToRefreshContentControllerAtIndex:(NSInteger)index {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self endRefreshing];
    });
}

@end
