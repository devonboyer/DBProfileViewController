//
//  DBProfileBlurImageOperation.m
//  DBProfileViewController
//
//  Created by Devon Boyer on 2016-03-12.
//  Copyright (c) 2015 Devon Boyer. All rights reserved.
//
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

#import "DBProfileBlurImageOperation.h"
#import "DBProfileImageEffects.h"
#import <FXBlurView/FXBlurView.h>

const NSInteger DBProfileBlurImageOperationNumberOfBlurredImages = 30;
const CGFloat DBProfileBlurImageOperationMaxBlurRadius = 20.0;

@interface DBProfileBlurImageOperation ()

@property (nonatomic, strong) UIImage *imageToBlur;

@end

@implementation DBProfileBlurImageOperation

- (instancetype)initWithImageToBlur:(UIImage *)imageToBlur {
    self = [super init];
    if (self) {
        self.imageToBlur = imageToBlur;
    }
    return self;
}

- (void)start {
    
    NSMutableDictionary *blurredImages = [[NSMutableDictionary alloc] init];
    for (int i = 0; i <= DBProfileBlurImageOperationNumberOfBlurredImages; i++) {
        CGFloat radius = DBProfileBlurImageOperationMaxBlurRadius * i/DBProfileBlurImageOperationNumberOfBlurredImages;
        [blurredImages setObject:[self.imageToBlur blurredImageWithRadius:radius iterations:10 tintColor:[UIColor clearColor]] forKey:[@(i) stringValue]];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.blurImageCompletionBlock) {
            self.blurImageCompletionBlock(blurredImages);
        }
    });
}

- (void)cancel {
    // TODO: Cancel blurring of any pending images
}

@end
