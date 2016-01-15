//
//  DBUserProfileViewController.m
//  Pods
//
//  Created by Devon Boyer on 2016-01-14.
//
//

#import "DBUserProfileViewController.h"

@implementation DBUserProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.coverPhotoStyle = DBProfileCoverPhotoStyleStretch;
    self.coverPhotoMimicsNavigationBar = YES;
    self.profilePictureAlignment = DBProfilePictureAlignmentLeft;
    self.profilePictureSize = DBProfilePictureSizeDefault;
    self.allowsPullToRefresh = YES;
}

@end
