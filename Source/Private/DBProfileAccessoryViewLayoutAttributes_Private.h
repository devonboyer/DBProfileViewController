//
//  DBProfileAccessoryViewLayoutAttributes_Private.h
//  DBProfileViewController
//
//  Created by Devon Boyer on 2016-05-13.
//  Copyright (c) 2015 Devon Boyer. All rights reserved.
//

#import "DBProfileAccessoryViewLayoutAttributes.h"

@interface DBProfileAccessoryViewLayoutAttributes ()

@property (nonatomic) BOOL hasInstalledConstraints;

- (void)uninstallConstraints;

@property (nonatomic, nullable) NSLayoutConstraint *leadingConstraint;
@property (nonatomic, nullable) NSLayoutConstraint *trailingConstraint;
@property (nonatomic, nullable) NSLayoutConstraint *leftConstraint;
@property (nonatomic, nullable) NSLayoutConstraint *rightConstraint;
@property (nonatomic, nullable) NSLayoutConstraint *topConstraint;
@property (nonatomic, nullable) NSLayoutConstraint *bottomConstraint;
@property (nonatomic, nullable) NSLayoutConstraint *widthConstraint;
@property (nonatomic, nullable) NSLayoutConstraint *heightConstraint;
@property (nonatomic, nullable) NSLayoutConstraint *centerXConstraint;
@property (nonatomic, nullable) NSLayoutConstraint *centerYConstraint;
@property (nonatomic, nullable) NSLayoutConstraint *firstBaselineConstraint;
@property (nonatomic, nullable) NSLayoutConstraint *lastBaselineConstraint;

@end
