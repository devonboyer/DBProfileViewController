//
//  DBProfileNavigationBar.m
//  Pods
//
//  Created by Devon Boyer on 2016-01-09.
//
//

#import "DBProfileNavigationBar.h"

@implementation DBProfileNavigationBar

#pragma mark - Initialization

- (instancetype)init {
    self = [super init];
    if (self) {
        [self _commonInit];
    }
    return self;
}

- (void)_commonInit {
    [self setBackgroundImage:[UIImage new]forBarMetrics:UIBarMetricsDefault];
    self.shadowImage = [UIImage new];
    self.translucent = YES;
    self.backgroundColor = [UIColor clearColor];
    self.tintColor = [UIColor whiteColor];
}

@end
