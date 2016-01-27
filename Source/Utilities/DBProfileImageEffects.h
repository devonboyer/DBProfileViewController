//
//  DBProfileImageEffects.h
//  Pods
//
//  Created by Devon Boyer on 2016-01-25.
//
//

#import <Foundation/Foundation.h>

@interface DBProfileImageEffects : NSObject

+ (UIImage *)imageByApplyingBlurToImage:(UIImage *)image withRadius:(CGFloat)radius;

// http://www.samwirch.com/blog/cropping-and-resizing-images-camera-ios-and-objective-c
+ (UIImage *)imageByCroppingImage:(UIImage *)image withSize:(CGSize)newSize;

@end
