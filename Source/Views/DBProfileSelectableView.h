//
//  DBProfileSelectableView.h
//  Pods
//
//  Created by Devon Boyer on 2016-03-17.
//
//

#import <UIKit/UIKit.h>

@interface DBProfileSelectableView : UIView

@property (nonatomic, strong, readonly) UIView *selectedBackgroundView;

@property (nonatomic, assign, getter=isSelected) BOOL selected;

- (void)setSelected:(BOOL)selected animated:(BOOL)animated;

@property (nonatomic, assign, getter=isHighlighted) BOOL highlighted;

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated;

@end
