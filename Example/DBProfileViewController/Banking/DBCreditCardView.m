//
//  DBCreditCardView.m
//  DBProfileViewController
//
//  Created by Devon Boyer on 2016-04-16.
//  Copyright © 2016 Devon Boyer. All rights reserved.
//

#import "DBCreditCardView.h"

@implementation DBCreditCardView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.layoutMargins = UIEdgeInsetsMake(70, 15, 30, 15);
        self.contentView.layer.cornerRadius = 8;
        self.contentView.backgroundColor = [UIColor colorWithRed:107/255.0 green:95/255.0 blue:232/255.0 alpha:1];
    }
    return self;
}

@end
