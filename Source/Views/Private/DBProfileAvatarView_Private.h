//
//  DBProfileAvatarView_Private.h
//  Pods
//
//  Created by Devon Boyer on 2016-03-24.
//
//

#import "DBProfileAvatarView.h"

@protocol DBProfileAvatarViewDelegate <NSObject>

- (void)didSelectAvatarView:(DBProfileAvatarView *)avatarView;
- (void)didDeselectAvatarView:(DBProfileAvatarView *)avatarView;
- (void)didHighlightAvatarView:(DBProfileAvatarView *)avatarView;
- (void)didUnhighlightAvatarView:(DBProfileAvatarView *)avatarView;

@end

@interface DBProfileAvatarView ()

@property (nonatomic, weak) id<DBProfileAvatarViewDelegate> delegate;

@end