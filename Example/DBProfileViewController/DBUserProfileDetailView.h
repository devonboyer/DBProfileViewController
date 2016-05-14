//
//  DBUserProfileDetailView.h
//  DBProfileViewController
//
//  Created by Devon Boyer on 2016-03-21.
//  Copyright © 2016 Devon Boyer. All rights reserved.
//

#import <DBProfileViewController/DBProfileViewController.h>

@class DBUserProfileDetailView;

@protocol DBUserProfileDetailViewDelegate <NSObject>

- (void)userProfileDetailView:(DBUserProfileDetailView *)detailView didShowSupplementaryView:(UIView *)view;

@end

@interface DBUserProfileDetailView : UIView

@property (nonatomic, weak) id<DBUserProfileDetailViewDelegate> delegate;

@property (nonatomic, strong, readonly) UIView *contentView;
@property (nonatomic, strong, readonly) UILabel *nameLabel;
@property (nonatomic, strong, readonly) UILabel *usernameLabel;
@property (nonatomic, strong, readonly) UILabel *descriptionLabel;

@end
