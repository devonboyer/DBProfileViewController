//
//  DBProfileSegmentedControlView.h
//  DBProfileViewController
//
//  Created by Devon Boyer on 2016-01-08.
//  Copyright (c) 2015 Devon Boyer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DBProfileViewController/DBProfileSegmentedControl.h>

@interface DBProfileSegmentedControlView : UIView

@property (nonatomic) UIControl<DBProfileSegmentedControl> *segmentedControl;
@property (nonatomic) BOOL showsTopBorder;
@property (nonatomic) BOOL showsBottomBorder;

@end
