//
//  DBProfileSelectableView.h
//  Pods
//
//  Created by Devon Boyer on 2016-03-17.
//
//

#import <UIKit/UIKit.h>

@class DBProfileSelectableView;

@interface DBProfileSelectableView : UIView

@property (nonatomic, assign, getter=isHighlighted) BOOL highlighted;

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated;

@end
