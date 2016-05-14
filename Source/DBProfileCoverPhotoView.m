//
//  DBProfileCoverPhotoView.m
//  DBProfileViewController
//
//  Created by Devon Boyer on 2016-01-08.
//  Copyright (c) 2015 Devon Boyer. All rights reserved.
//

#import "DBProfileCoverPhotoView.h"
#import "DBProfileUtilities.h"
#import "DBProfileTintView.h"
#import "DBProfileHeaderViewLayoutAttributes.h"

@interface DBProfileCoverPhotoView ()

@property (nonatomic) DBProfileTintView *tintView;
@property (nonatomic) UIImage *originalImage;

@end

@implementation DBProfileCoverPhotoView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.userInteractionEnabled = YES;
        self.clipsToBounds = YES;
        _shouldCropImageBeforeBlurring = YES;
        
        _tintView = [[DBProfileTintView alloc] init];
        
        self.tintView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.tintView.frame = self.frame;
        
        [self addSubview:self.tintView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    // Bring the highlighted background view to the front so highlighting dims the view
    [self bringSubviewToFront:self.highlightedBackgroundView];
}

- (void)setShouldApplyTint:(BOOL)shouldApplyTint {
    _shouldApplyTint = shouldApplyTint;
    self.tintView.hidden = !shouldApplyTint;
}

- (void)setShouldCropImageBeforeBlurring:(BOOL)shouldCropImageBeforeBlurring {
    _shouldCropImageBeforeBlurring = shouldCropImageBeforeBlurring;
    [self setCoverPhotoImage:self.originalImage animated:NO];
}

- (void)setCoverPhotoImage:(UIImage *)coverPhotoImage animated:(BOOL)animated {
    self.originalImage = coverPhotoImage;
    
    UIImage *preparedImage = (self.shouldCropImageBeforeBlurring) ? DBProfileImageByCroppingImageToSize(coverPhotoImage, self.frame.size) : coverPhotoImage;
    
    if (animated) {
        [UIView transitionWithView:self
                          duration:0.15f
                           options:(UIViewAnimationOptionTransitionCrossDissolve | UIViewAnimationOptionBeginFromCurrentState)
                        animations:^{
                            self.initialImage = preparedImage;
                        }
                        completion:nil];
    } else {
        self.initialImage = preparedImage;
    }
}

- (void)applyLayoutAttributes:(DBProfileHeaderViewLayoutAttributes *)layoutAttributes {
    [super applyLayoutAttributes:layoutAttributes];
    
    if (layoutAttributes.headerStyle == DBProfileHeaderStyleDefault) {
        self.shouldApplyTint = NO;
    }
}

@end
