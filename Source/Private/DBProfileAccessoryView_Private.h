//
//  DBProfileAccessoryView_Private.h
//  DBProfileViewController
//
//  Created by Devon Boyer on 2016-04-02.
//  Copyright (c) 2015 Devon Boyer. All rights reserved.
//

#import "DBProfileAccessoryView.h"

NS_ASSUME_NONNULL_BEGIN

@protocol DBProfileAccessoryViewDelegate <NSObject>

- (BOOL)accessoryViewShouldHighlight:(DBProfileAccessoryView *)accessoryView;
- (void)accessoryViewDidHighlight:(DBProfileAccessoryView *)accessoryView;
- (void)accessoryViewDidUnhighlight:(DBProfileAccessoryView *)accessoryView;
- (void)accessoryViewWasTapped:(DBProfileAccessoryView *)accessoryView;
- (void)accessoryViewWasLongPressed:(DBProfileAccessoryView *)accessoryView;

@end

@interface DBProfileAccessoryView ()

@property (nonatomic, weak) id<DBProfileAccessoryViewDelegate> internalDelegate;

@property (nonatomic, copy) NSString *representedAccessoryKind;

@end

NS_ASSUME_NONNULL_END
