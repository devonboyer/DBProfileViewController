//
//  DBProfileTintedImageView.m
//  Pods
//
//  Created by Devon Boyer on 2016-03-21.
//
//

#import "DBProfileTintedImageView.h"
#import <FXBlurView/FXBlurView.h>

UIImage *DBProfileImageByBlurringImage(UIImage *image, UIColor *tintColor, CGFloat radius) {
    return [image blurredImageWithRadius:radius iterations:10 tintColor:tintColor];
}

UIImage *DBProfileImageByScalingImageToSize(UIImage *image, CGSize size) {
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

@interface DBProfileBlurredImageCacheKey : NSObject

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) UIColor *tintColor;
@property (nonatomic, assign) CGFloat radius;

- (instancetype)initWithImage:(UIImage *)image tintColor:(UIColor *)tintColor radius:(CGFloat)radius;

@end


@implementation DBProfileBlurredImageCacheKey

- (instancetype)initWithImage:(UIImage *)image tintColor:(UIColor *)tintColor radius:(CGFloat)radius {
    self = [super init];
    if (self) {
        _image = image;
        _tintColor = tintColor;
        _radius = radius;
    }
    return self;
}

- (BOOL)isEqual:(id)object {
    if ([self class] != [object class]) {
        return NO;
    }
    __typeof(self) castObject = object;
    return ([_image isEqual:castObject.image]
            && [_tintColor isEqual:castObject.tintColor]
            && _radius == castObject.radius);
}

@end

@interface DBProfileBlurredImageCache : NSCache

- (UIImage *)blurredImageForImage:(UIImage *)image tintColor:(UIColor *)tintColor radius:(CGFloat)radius;

@end


@implementation DBProfileBlurredImageCache

+ (instancetype)sharedCache {
    static dispatch_once_t pred;
    static id sharedInstance = nil;
    dispatch_once(&pred, ^{
        sharedInstance = [[[self class] alloc] init];
    });
    return sharedInstance;
}

- (UIImage *)blurredImageForImage:(UIImage *)image tintColor:(UIColor *)tintColor radius:(CGFloat)radius {
    UIImage *blurredImage = nil;
    
    DBProfileBlurredImageCacheKey *key = [[DBProfileBlurredImageCacheKey alloc] initWithImage:image tintColor:tintColor radius:radius];
    blurredImage = [self objectForKey:key];
    if (!blurredImage) {
        blurredImage = DBProfileImageByBlurringImage(image, tintColor, radius);
        if (blurredImage) {
            [self setObject:blurredImage forKey:key];
        }
    }
    return blurredImage;
}

- (void)cacheImage:(UIImage *)image tintColor:(UIColor *)tintColor radius:(CGFloat)radius {
    [self blurredImageForImage:image tintColor:tintColor radius:radius];
}

@end

@interface DBProfileTintView : UIView
@end

@implementation DBProfileTintView

+ (Class)layerClass {
    return [CAGradientLayer class];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CAGradientLayer *gradientLayer = (CAGradientLayer *)self.layer;
    
    gradientLayer.colors = @[(id)[UIColor colorWithWhite:0.0f alpha:0.5f].CGColor,
                             (id)[UIColor colorWithWhite:0.0f alpha:0.4f].CGColor,
                             (id)[UIColor colorWithWhite:0.0f alpha:0.3f].CGColor,
                             (id)[UIColor colorWithWhite:0.0f alpha:0.2f].CGColor,
                             (id)[UIColor colorWithWhite:0.0f alpha:0.0f].CGColor];
    
    gradientLayer.locations = @[[NSNumber numberWithFloat:0.0f],
                                [NSNumber numberWithFloat:0.2f],
                                [NSNumber numberWithFloat:0.4],
                                [NSNumber numberWithFloat:0.6f],
                                [NSNumber numberWithFloat:1.0f]];
}

@end

@implementation DBProfileTintedImageView {
    UIImage *_originalImage;
    UIColor *_appliedTintColor;
    DBProfileTintView *_tintView;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _tintView = [[DBProfileTintView alloc] init];
        _tintView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _tintView.frame = self.frame;
        [self addSubview:_tintView];
        
        _shouldCropImageBeforeBlurring = YES;
        _appliedTintColor = [UIColor clearColor];
    }
    return self;
}

- (void)setShouldApplyTint:(BOOL)shouldApplyTint {
    _shouldApplyTint = shouldApplyTint;
    _tintView.hidden = !shouldApplyTint;
}

- (void)setShouldCropImageBeforeBlurring:(BOOL)shouldCropImageBeforeBlurring {
    _shouldCropImageBeforeBlurring = shouldCropImageBeforeBlurring;
    [self setImage:_originalImage];
}

- (void)setImage:(UIImage *)image {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        _originalImage = self.shouldCropImageBeforeBlurring ? DBProfileImageByScalingImageToSize(image, self.frame.size) : image;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self _applyBlurWithRadius:0];
        });
    });
}

- (void)setBlurRadius:(CGFloat)blurRadius {
    _blurRadius = blurRadius;
    [self _applyBlurWithRadius:blurRadius];
}

- (void)_applyBlurWithRadius:(CGFloat)blurRadius {
    if (!_originalImage) return;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        UIImage *blurredImage = [[DBProfileBlurredImageCache sharedCache] blurredImageForImage:_originalImage
                                                                                     tintColor:_appliedTintColor
                                                                                        radius:round(blurRadius)];
        dispatch_async(dispatch_get_main_queue(), ^{
            [super setImage:blurredImage];
        });
    });
}

// 

@end
