//
//  DBProfileAccessoryViewModel.h
//  Pods
//
//  Created by Devon Boyer on 2016-05-08.
//
//

#import <Foundation/Foundation.h>

@class DBProfileAccessoryView;
@class DBProfileAccessoryViewLayoutAttributes;

@interface DBProfileAccessoryViewModel : NSObject

- (instancetype)initWithAccessoryView:(DBProfileAccessoryView *)accessoryView layoutAttributes:(DBProfileAccessoryViewLayoutAttributes *)layoutAttributes NS_DESIGNATED_INITIALIZER;

@property (nonatomic, readonly) NSString *representedAccessoryKind;

@property (nonatomic, readonly) DBProfileAccessoryView *accessoryView;

@property (nonatomic, readonly) DBProfileAccessoryViewLayoutAttributes *layoutAttributes;

@end
