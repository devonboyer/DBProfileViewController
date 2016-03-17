//
//  DBProfileItemChange.m
//  Pods
//
//  Created by Devon Boyer on 2016-03-14.
//
//

#import "DBProfileItemChange.h"

@interface DBProfileItemChange ()

@property (nonatomic, assign) DBProfileItemChangeType type;
@property (nonatomic, strong) id oldValue;
@property (nonatomic, strong) id changedValue;

@end

@implementation DBProfileItemChange

- (instancetype)initWithType:(DBProfileItemChangeType)type oldValue:(id)oldValue changedValue:(id)changeValue {
    self = [self init];
    if (self) {
        self.type = type;
        self.oldValue = oldValue;
        self.changedValue = changeValue;
    }
    return self;
}

- (instancetype)init {
    if (self) {
        self.type = DBProfileItemChangeTypeUpdate;
    }
    return self;
}

@end
