//
//  DBProfileAccessoryView_Private.h
//  Pods
//
//  Created by Devon Boyer on 2016-04-02.
//
//

#import "DBProfileAccessoryView.h"

@protocol DBProfileAccessoryViewDelegate <NSObject>

- (BOOL)accessoryViewShouldHighlight:(DBProfileAccessoryView *)accessoryView;
- (void)accessoryViewDidHighlight:(DBProfileAccessoryView *)accessoryView;
- (void)accessoryViewDidUnhighlight:(DBProfileAccessoryView *)accessoryView;
- (void)accessoryViewWasTapped:(DBProfileAccessoryView *)accessoryView;
- (void)accessoryViewWasLongPressed:(DBProfileAccessoryView *)accessoryView;

@end

@interface DBProfileAccessoryView ()

@property (nonatomic, weak) id<DBProfileAccessoryViewDelegate> internalDelegate;

@property (nonatomic, strong) NSString *representedAccessoryKind;

@end