//
//  DBUserProfileDetailsView.h
//  DBProfileViewController
//
//  Created by Devon Boyer on 2016-03-21.
//  Copyright © 2016 Devon Boyer. All rights reserved.
//

@import DBProfileViewController;

@class DBUserProfileDetailsView;

@protocol DBUserProfileDetailsViewDelegate <NSObject>

- (void)userProfileDetailsViewDidShowSuggestedFollowers:(DBUserProfileDetailsView *)detailsView;

@end

@interface DBUserProfileDetailsView : UIView

@property (nonatomic, weak) id<DBUserProfileDetailsViewDelegate> delegate;

@property (nonatomic, strong, readonly) UIView *contentView;
@property (nonatomic, strong, readonly) UILabel *nameLabel;
@property (nonatomic, strong, readonly) UILabel *usernameLabel;
@property (nonatomic, strong, readonly) UILabel *descriptionLabel;

@end
