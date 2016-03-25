//
//  DBProfileTintedImageView.h
//  Pods
//
//  Created by Devon Boyer on 2016-03-21.
//
//

#import <UIKit/UIKit.h>

@interface DBProfileTintedImageView : UIImageView

@property (nonatomic, assign) BOOL shouldApplyTint;
@property (nonatomic, assign) BOOL shouldCropImageBeforeBlurring;
@property (nonatomic, assign) CGFloat blurRadius;

@end
