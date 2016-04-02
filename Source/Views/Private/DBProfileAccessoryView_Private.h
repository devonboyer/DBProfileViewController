//
//  DBProfileAccessoryView_Private.h
//  Pods
//
//  Created by Devon Boyer on 2016-04-02.
//
//

#import "DBProfileAccessoryView.h"

@protocol DBProfileAccessoryViewDelegate <NSObject>

- (void)accessoryViewDidHighlight:(DBProfileAccessoryView *)accessoryView;
- (void)accessoryViewDidUnhighlight:(DBProfileAccessoryView *)accessoryView;
- (void)accessoryViewWasSelected:(DBProfileAccessoryView *)accessoryView;
- (void)accessoryViewWasDeselected:(DBProfileAccessoryView *)accessoryView;

@end

@interface DBProfileAccessoryView ()

@property (nonatomic, weak) id<DBProfileAccessoryViewDelegate> delegate;

@end