//
//  DBBlogProfileViewController.m
//  Pods
//
//  Created by Devon Boyer on 2016-01-14.
//
//

#import "DBBlogProfileViewController.h"

@implementation DBBlogProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.coverPhotoStyle = DBProfileCoverPhotoStyleBackdrop;
    self.coverPhotoMimicsNavigationBar = YES;
    self.profilePictureAlignment = DBProfilePictureAlignmentLeft;
    self.profilePictureSize = DBProfilePictureSizeDefault;
    self.profilePictureInset = UIEdgeInsetsMake(0, 15, 0, 0);
    self.allowsPullToRefresh = YES;
}

@end
