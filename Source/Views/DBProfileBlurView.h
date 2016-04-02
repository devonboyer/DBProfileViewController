//
//  DBProfileBlurView.h
//  DBProfileViewController
//
//  Created by Devon Boyer on 2016-03-25.
//  Copyright (c) 2015 Devon Boyer. All rights reserved.
//
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

#import "DBProfileAccessoryView.h"
#import "DBProfileTintedImageView.h"

@interface DBProfileBlurView : DBProfileAccessoryView

@property (nonatomic, strong, readonly) DBProfileTintedImageView *imageView;

@property (nonatomic, assign, getter = isBlurEnabled) BOOL blurEnabled;
@property (nonatomic, assign) BOOL shouldInterpolateStages;
@property (nonatomic, assign) NSUInteger numberOfStages;
@property (nonatomic, assign) CGFloat maxBlurRadius;
@property (nonatomic, assign) CGFloat percentScrolled;
@property (nonatomic, strong) UIImage *initialImage;

@end