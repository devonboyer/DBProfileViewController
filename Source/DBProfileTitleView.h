//
//  DBProfileTitleView.h
//  DBProfileViewController
//
//  Created by Devon Boyer on 2016-01-10.
//  Copyright (c) 2015 Devon Boyer. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DBProfileTitleView : UIView

@property (nonatomic, readonly) UILabel *titleLabel;

@property (nonatomic, readonly) UILabel *subtitleLabel;

@property (nonatomic, copy, nullable) NSString *title;

@property (nonatomic, copy, nullable) NSString *subtitle;

@property (nonatomic) BOOL wantsShadowForLabels;

@end

NS_ASSUME_NONNULL_END
