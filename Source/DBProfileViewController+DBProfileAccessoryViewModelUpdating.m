//
//  DBProfileViewController+DBProfileAccessoryViewModelUpdating.m
//  DBProfileViewController
//
//  Created by Devon Boyer on 2016-05-08.
//  Copyright (c) 2015 Devon Boyer. All rights reserved.
//

#import "DBProfileViewController+DBProfileAccessoryViewModelUpdating.h"

@implementation DBProfileViewController (DBProfileAccessoryViewModelUpdating)

- (void)updateLayoutAttributeFromValue:(id)fromValue
                               toValue:(id)toValue
                 forAccessoryViewModel:(DBProfileAccessoryViewModel *)viewModel
{
    // FIXME: Ideally we only need to invalidate the specific attribute that was updated
    // Considering using an invalidation context to specify which atttributes need updating
    [self invalidateLayoutAttributesForAccessoryViewOfKind:viewModel.representedAccessoryKind];
}

@end
