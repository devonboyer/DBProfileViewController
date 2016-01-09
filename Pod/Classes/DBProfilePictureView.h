//
//  DBProfilePictureView.h
//  Pods
//
//  Created by Devon Boyer on 2016-01-08.
//
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, DBProfilePictureStyle) {
    DBProfilePictureStyleRound,
    DBProfilePictureStyleRoundedRect,
};

@interface DBProfilePictureView : UIView

@property (nonatomic, strong, readonly) UIImageView *imageView;
@property (nonatomic, assign) DBProfilePictureStyle style;

@end
