//
//  DBProfileCoverPhotoView_Private.h
//  Pods
//
//  Created by Devon Boyer on 2016-03-24.
//
//

#import "DBProfileCoverPhotoView.h"

@protocol DBProfileCoverPhotoViewDelegate <NSObject>

- (void)didSelectCoverPhotoView:(DBProfileCoverPhotoView *)coverPhotoView;
- (void)didDeselectCoverPhotoView:(DBProfileCoverPhotoView *)coverPhotoView;
- (void)didHighlightCoverPhotoView:(DBProfileCoverPhotoView *)coverPhotoView;
- (void)didUnhighlightCoverPhotoView:(DBProfileCoverPhotoView *)coverPhotoView;

@end

@interface DBProfileCoverPhotoView ()

@property (nonatomic, weak) id<DBProfileCoverPhotoViewDelegate> delegate;

@end