//
//  DBProfileItem.m
//  Pods
//
//  Created by Devon Boyer on 2016-03-14.
//
//

#import "DBProfileItem.h"

@interface DBProfileItem ()

@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) id<DBProfileItemValue> value;

@end

@implementation DBProfileItem

- (instancetype)initWithTitle:(NSString *)title value:(id<DBProfileItemValue>)value {
    self = [self init];
    if (self) {
        self.title = title;
        self.value = value;
    }
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.editable = YES;
        self.maxNumberOfLines = 1;
    }
    return self;
}

@end
