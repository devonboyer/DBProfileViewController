//
//  DBProfileCoverPhotoView.m
//  DBProfileViewController
//
//  Created by Devon Boyer on 2016-01-08.
//  Copyright (c) 2015 Devon Boyer. All rights reserved.
//
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

#import "DBProfileCoverPhotoView.h"
#import "DBProfileTintedImageView.h"
#import "DBProfileCoverPhotoView_Private.h"

UIImage *DBProfileImageByScalingImageToSize(UIImage *image, CGSize size){
    
    CGFloat oldWidth = image.size.width;
    CGFloat oldHeight = image.size.height;
    
    CGFloat scaleFactor = (oldWidth > oldHeight) ? size.width / oldWidth : size.height / oldHeight;
    
    CGFloat newHeight = oldHeight * scaleFactor;
    CGFloat newWidth = oldWidth * scaleFactor;
    CGSize newSize = CGSizeMake(newWidth, newHeight);
    
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        UIGraphicsBeginImageContextWithOptions(newSize, NO, [[UIScreen mainScreen] scale]);
    } else {
        UIGraphicsBeginImageContext(newSize);
    }
    
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

@implementation DBProfileCoverPhotoView {
    DBProfileBlurView *_blurView;
    DBProfileTintedImageView *_tintView;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.userInteractionEnabled = YES;
        self.clipsToBounds = YES;
        self.shouldCropImageBeforeBlurring = YES;
        
        _blurView = [[DBProfileBlurView alloc] init];
        _blurView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:_blurView];
        
        _tintView = [[DBProfileTintedImageView alloc] init];
        _tintView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [_blurView addSubview:_tintView];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    if (selected && [self.delegate respondsToSelector:@selector(didSelectCoverPhotoView:)]) {
        [self.delegate didSelectCoverPhotoView:self];
    }
    else if (!selected && [self.delegate respondsToSelector:@selector(didDeselectCoverPhotoView:)]) {
        [self.delegate didDeselectCoverPhotoView:self];
    }
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    
    if (highlighted && [self.delegate respondsToSelector:@selector(didHighlightCoverPhotoView:)]) {
        [self.delegate didHighlightCoverPhotoView:self];
    }
    else if (!highlighted && [self.delegate respondsToSelector:@selector(didUnhighlightCoverPhotoView:)]) {
        [self.delegate didUnhighlightCoverPhotoView:self];
    }
}

- (void)setShouldApplyTint:(BOOL)shouldApplyTint {
    _shouldApplyTint = shouldApplyTint;
    _tintView.shouldApplyTint = shouldApplyTint;
}

- (void)setCoverPhotoImage:(UIImage *)image animated:(BOOL)animated {
    if (!image) return;
    CGSize coverPhotoSize = _blurView.frame.size;
    _blurView.snapshot = (self.shouldCropImageBeforeBlurring) ? DBProfileImageByScalingImageToSize(image, coverPhotoSize) : image;
    
    if (animated) {
        _blurView.alpha = 0;
        [UIView animateWithDuration: 0.3 animations:^{
            _blurView.alpha = 1;
        }];
    }
}

@end
