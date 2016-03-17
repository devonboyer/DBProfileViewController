//
//  DBProfileItemChange.h
//  Pods
//
//  Created by Devon Boyer on 2016-03-14.
//
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, DBProfileItemChangeType) {
    DBProfileItemChangeTypeUpdate
};

@interface DBProfileItemChange<ObjectType> : NSObject

- (instancetype)initWithType:(DBProfileItemChangeType)type oldValue:(ObjectType)oldValue changedValue:(ObjectType)changeValue;

@property (nonatomic, assign, readonly) DBProfileItemChangeType type;

@property (nonatomic, strong, readonly) ObjectType oldValue;

@property (nonatomic, strong, readonly) ObjectType changedValue;

@end
