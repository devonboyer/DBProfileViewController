//
//  DBEditProfileItem.h
//  Pods
//
//  Created by Devon Boyer on 2016-03-13.
//
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, DBEditProfileItemType) {
    DBEditProfileItemTypeText,
    DBEditProfileItemTypeTextMultiLine,
    DBEditProfileItemTypeToggle,
    DBEditProfileItemTypeDate,
    DBEditProfileItemTypeLocation,
};

@interface DBEditProfileItem : NSObject

- (instancetype)initWithTitle:(NSString *)title placeholder:(NSString *)placeholder type:(DBEditProfileItemType)type;

@property (nonatomic, copy) NSString *title;

@property (nonatomic, copy) NSString *placeholder;

@property (nonatomic, assign, getter=isEditable) BOOL editable;

@property (nonatomic, assign) DBEditProfileItemType type;

@end
