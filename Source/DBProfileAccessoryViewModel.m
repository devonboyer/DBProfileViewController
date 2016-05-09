//
//  DBProfileAccessoryViewModel.m
//  DBProfileViewController
//
//  Created by Devon Boyer on 2016-05-08.
//  Copyright (c) 2015 Devon Boyer. All rights reserved.
//

#import "DBProfileAccessoryViewModel.h"
#import "DBProfileAccessoryView.h"
#import "DBProfileAccessoryViewLayoutAttributes.h"

@implementation DBProfileAccessoryViewModel

- (instancetype)initWithAccessoryView:(DBProfileAccessoryView *)accessoryView layoutAttributes:(DBProfileAccessoryViewLayoutAttributes *)layoutAttributes {
    self = [super init];
    if (self) {
        _accessoryView = accessoryView;
        _layoutAttributes = layoutAttributes;
    }
    return self;
}

- (NSString *)representedAccessoryKind {
    return self.layoutAttributes.representedAccessoryKind;
}

#pragma mark - NSObject

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[self class]]) return NO;
    DBProfileAccessoryViewModel *otherObject = (DBProfileAccessoryViewModel *)object;
    return self.representedAccessoryKind == otherObject.representedAccessoryKind;
}

@end
