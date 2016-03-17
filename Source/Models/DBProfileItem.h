//
//  DBProfileItem.h
//  Pods
//
//  Created by Devon Boyer on 2016-03-14.
//
//

#import <Foundation/Foundation.h>

@protocol DBProfileItemValue <NSObject>
@end

@interface NSString () <DBProfileItemValue>
@end

@interface NSURL () <DBProfileItemValue>
@end

@interface DBProfileItem : NSObject

- (instancetype)initWithTitle:(NSString *)title value:(id<DBProfileItemValue>)value;

@property (nonatomic, copy, readonly) NSString *title;

@property (nonatomic, strong, readonly) id<DBProfileItemValue> value;

@property (nonatomic, assign, getter=isEditable) BOOL editable; // default is YES

@property (nonatomic, assign) NSInteger maxNumberOfLines; // default is 1

@end