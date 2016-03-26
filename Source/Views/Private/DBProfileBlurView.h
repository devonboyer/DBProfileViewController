//
//  DBProfileBlurView.h
//  Pods
//
//  Created by Devon Boyer on 2016-03-25.
//
//

#import <UIKit/UIKit.h>

@interface DBProfileBlurView : UIView

@property (nonatomic, strong) UIImage *snapshot;

@property (nonatomic, assign) NSUInteger iterations;
@property (nonatomic, assign) NSUInteger numberOfStages;
@property (nonatomic, assign) NSInteger stage;
@property (nonatomic, assign) CGFloat maxBlurRadius;

- (void)updateAsynchronously:(BOOL)async completion:(void (^)())completion;

@end