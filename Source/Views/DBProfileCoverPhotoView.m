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
#import "DBProfileBlurView.h"
#import "DBProfileTintedImageView.h"
#import "DBProfileCoverPhotoView_Private.h"

UIImage *DBProfileImageByScalingImageToSize(UIImage *image, CGSize size) {
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
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.userInteractionEnabled = YES;
        self.clipsToBounds = YES;
        
        _blurView = [[DBProfileBlurView alloc] init];
        _blurView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:_blurView];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    if (selected && [self.delegate respondsToSelector:@selector(didSelectCoverPhotoView:)]) {
        [self.delegate didSelectCoverPhotoView:self];
    } else if (!selected && [self.delegate respondsToSelector:@selector(didDeselectCoverPhotoView:)]) {
        [self.delegate didDeselectCoverPhotoView:self];
    }
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    
    if (highlighted && [self.delegate respondsToSelector:@selector(didHighlightCoverPhotoView:)]) {
        [self.delegate didHighlightCoverPhotoView:self];
    } else if (!highlighted && [self.delegate respondsToSelector:@selector(didUnhighlightCoverPhotoView:)]) {
        [self.delegate didUnhighlightCoverPhotoView:self];
    }
}

- (void)setBlurRadius:(CGFloat)blurRadius {
    _blurView.stage = round(blurRadius);
}

- (void)setCoverPhotoImage:(UIImage *)image animated:(BOOL)animated {
    if (!image) return;
        
    _blurView.snapshot = image;
}

@end
