//
//  DBProfileBlurImageOperation.h
//  DBProfileViewController
//
//  Created by Devon Boyer on 2016-03-12.
//  Copyright (c) 2015 Devon Boyer. All rights reserved.
//
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

#import <Foundation/Foundation.h>

extern const NSInteger DBProfileBlurImageOperationNumberOfBlurredImages;
extern const CGFloat DBProfileBlurImageOperationMaxBlurRadius;

@interface DBProfileBlurImageOperation : NSOperation

- (instancetype)initWithImageToBlur:(UIImage *)imageToBlur;

@property(nonatomic, copy) void (^blurImageCompletionBlock)(NSDictionary *blurredImages);

@end
