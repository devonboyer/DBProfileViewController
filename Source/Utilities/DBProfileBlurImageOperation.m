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
#import <FXBlurView/FXBlurView.h>

@interface DBProfileBlurImageOperation ()

@property (nonatomic, strong) UIImage *imageToBlur;

@end

@implementation DBProfileBlurImageOperation

- (instancetype)initWithImageToBlur:(UIImage *)imageToBlur {
    self = [self init];
    if (self) {
        self.imageToBlur = imageToBlur;
    }
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.numberOfBlurredImages = 30;
        self.maxBlurRadius = 20.0;
        self.iterationsPerImage = 10;
    }
    return self;
}

- (void)start {
    NSMutableDictionary *blurredImages = [[NSMutableDictionary alloc] init];
    
    for (int i = 0; i < self.numberOfBlurredImages; i++) {
        if (self.cancelled) {
            break;
        }
        
        CGFloat radius = self.maxBlurRadius * i/self.numberOfBlurredImages;
        UIImage *blurredImage = [self.imageToBlur blurredImageWithRadius:radius
                                                              iterations:self.iterationsPerImage
                                                               tintColor:[UIColor clearColor]];
        [blurredImages setObject:blurredImage forKey:[@(i) stringValue]];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.blurImageCompletionBlock) {
            self.blurImageCompletionBlock(blurredImages);
        }
    });
}

@end
