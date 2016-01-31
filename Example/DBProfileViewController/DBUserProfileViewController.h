//
//  DBUserProfileViewController.h
//  DBProfileViewController
//
//  Created by Devon Boyer on 2016-01-15.
//  Copyright © 2016 Devon Boyer. All rights reserved.
//

@import DBProfileViewController;

typedef NS_ENUM(NSInteger, DBUserProfileViewControllerStyle) {
    DBUserProfileViewControllerStyle1,
    DBUserProfileViewControllerStyle2,
    DBUserProfileViewControllerStyle3
};

@interface DBUserProfileViewController : DBProfileViewController

@property (nonatomic, assign) DBUserProfileViewControllerStyle style;

@end
