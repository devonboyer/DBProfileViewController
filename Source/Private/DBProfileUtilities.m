//
//  DBProfileUtilities.m
//  Pods
//
//  Created by Devon Boyer on 2016-05-13.
//
//

#import "DBProfileUtilities.h"

CGFloat DBProfileDesiredNavigationBarHeightForTraitCollection(UITraitCollection *traitCollection) {
    switch (traitCollection.verticalSizeClass) {
        case UIUserInterfaceSizeClassCompact:
            return 32;
        default:
            return 64;
    }
}

UIImage *DBProfileImageByCroppingImageToSize(UIImage *image, CGSize size) {
    
    CGFloat oldWidth = image.size.width;
    CGFloat oldHeight = image.size.height;
    
    CGFloat scaleFactor = (oldWidth > oldHeight) ? size.width / oldWidth : size.height / oldHeight;
    
    CGFloat newHeight = oldHeight * scaleFactor;
    CGFloat newWidth = oldWidth * scaleFactor;
    CGSize newSize = CGSizeMake(newWidth, newHeight);
    
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        UIGraphicsBeginImageContextWithOptions(newSize, NO, [[UIScreen mainScreen] scale]);
    } else {
        UIGraphicsBeginImageContext(newSize);
    }
    
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}
