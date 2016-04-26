//
//  DBProfileHeaderViewNavigationBar.h
//  DBProfileViewController
//
//  Created by Devon Boyer on 2016-01-13.
//  Copyright (c) 2015 Devon Boyer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DBProfileHeaderViewNavigationBar : UINavigationBar

- (void)setTitle:(NSString *)title;
- (void)setSubtitle:(NSString *)subtitle traitCollection:(UITraitCollection *)traitCollection;
- (void)setTitleVerticalPositionAdjustment:(CGFloat)adjustment traitCollection:(UITraitCollection *)traitCollection;

@end