//
//  DBProfileCustomNavigationBar.m
//  DBProfileViewController
//
//  Created by Devon Boyer on 2016-01-13.
//  Copyright (c) 2015 Devon Boyer. All rights reserved.
//
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

#import "DBProfileCustomNavigationBar.h"
#import "DBProfileTitleView.h"

@implementation DBProfileCustomNavigationBar {
    DBProfileTitleView *_titleView;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
        self.shadowImage = [[UIImage alloc] init];
        self.tintColor = [UIColor whiteColor];
        self.translucent = YES;
        self.clipsToBounds = YES;
        
        _navigationItem = [[UINavigationItem alloc] init];
        _titleView = [[DBProfileTitleView alloc] init];
        
        self.items = @[self.navigationItem];

        self.navigationItem.titleView = _titleView;
    }
    return self;
}
- (void)setTitle:(NSString *)title {
    [_titleView setTitle:title];
    _titleView.titleLabel.text = title;
}

- (void)setSubtitle:(NSString *)subtitle traitCollection:(UITraitCollection *)traitCollection {
    switch (traitCollection.verticalSizeClass) {
        case UIUserInterfaceSizeClassCompact:
            [_titleView setSubtitle:nil];
            break;
        default:
            [_titleView setSubtitle:subtitle];
            break;
    }
}

- (void)setTitleVerticalPositionAdjustment:(CGFloat)adjustment traitCollection:(UITraitCollection *)traitCollection {
    if (traitCollection.verticalSizeClass == UIUserInterfaceSizeClassCompact) {
        [self setTitleVerticalPositionAdjustment:adjustment forBarMetrics:UIBarMetricsCompact];
    } else {
        [self setTitleVerticalPositionAdjustment:adjustment forBarMetrics:UIBarMetricsDefault];
    }
}

@end
