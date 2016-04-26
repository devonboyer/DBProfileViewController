//
//  DBProfileTintView.m
//  DBProfileViewController
//
//  Created by Devon Boyer on 2016-04-08.
//  Copyright (c) 2015 Devon Boyer. All rights reserved.
//

#import "DBProfileTintView.h"

@interface DBProfileTintLayer : CAGradientLayer

@end

@implementation DBProfileTintLayer
@end

@implementation DBProfileTintView

+ (Class)layerClass {
    return [DBProfileTintLayer class];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    DBProfileTintLayer *tintLayer = (DBProfileTintLayer *)self.layer;
    
    tintLayer.colors = @[(id)[UIColor colorWithWhite:0.0f alpha:0.5f].CGColor,
                         (id)[UIColor colorWithWhite:0.0f alpha:0.4f].CGColor,
                         (id)[UIColor colorWithWhite:0.0f alpha:0.3f].CGColor,
                         (id)[UIColor colorWithWhite:0.0f alpha:0.2f].CGColor,
                         (id)[UIColor colorWithWhite:0.0f alpha:0.0f].CGColor];
    
    tintLayer.locations = @[[NSNumber numberWithFloat:0.0f],
                            [NSNumber numberWithFloat:0.2f],
                            [NSNumber numberWithFloat:0.4],
                            [NSNumber numberWithFloat:0.6f],
                            [NSNumber numberWithFloat:1.0f]];
}

@end
