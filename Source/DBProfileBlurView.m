//
//  DBProfileBlurView.m
//  DBProfileViewController
//
//  Created by Devon Boyer on 2016-03-25.
//  Copyright (c) 2015 Devon Boyer. All rights reserved.
//

#import "DBProfileBlurView.h"
#import "DBProfileHeaderViewLayoutAttributes.h"
#import <FXBlurView/FXBlurView.h>

@interface DBProfileBlurStageCacheKey : NSObject

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) UIColor *tintColor;
@property (nonatomic, assign) NSUInteger stage;

@end

@implementation DBProfileBlurStageCacheKey

- (instancetype)initWithImage:(UIImage *)image tintColor:(UIColor *)tintColor stage:(NSUInteger)stage
{
    self = [super init];
    if (self) {
        _image = image;
        _tintColor = tintColor;
        _stage = stage;
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
            && _stage == castObject.stage);
}

@end

@interface DBProfileBlurStageCache : NSCache
@end

@implementation DBProfileBlurStageCache

- (UIImage *)blurredImageForImage:(UIImage *)image tintColor:(UIColor *)tintColor stage:(NSUInteger)stage
{
    DBProfileBlurStageCacheKey *key = [[DBProfileBlurStageCacheKey alloc] initWithImage:image
                                                                              tintColor:tintColor
                                                                                  stage:stage];
    return [self objectForKey:key];
}

- (void)setBlurredImage:(UIImage *)blurredImage forImage:(UIImage *)image tintColor:(UIColor *)tintColor stage:(NSUInteger)stage
{
    DBProfileBlurStageCacheKey *key = [[DBProfileBlurStageCacheKey alloc] initWithImage:image
                                                                              tintColor:tintColor
                                                                                  stage:stage];
    [self setObject:blurredImage forKey:key];
}

@end

@interface DBProfileBlurView ()

@property (nonatomic) UIImageView *interpolatedImageView;
@property (nonatomic) DBProfileBlurStageCache *cache;
@property (nonatomic) NSUInteger iterations;
@property (nonatomic) NSInteger stage;

- (void)updateAsync:(BOOL)async completion:(void (^)())completion;

@end

@implementation DBProfileBlurView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.clipsToBounds = YES;
        self.backgroundColor = [UIColor whiteColor];
        self.tintColor = [UIColor clearColor];
        
        self.blurEnabled = YES;
        self.iterations = 5;
        self.maxBlurRadius = 20.0;
        self.numberOfStages = 20;
        self.shouldInterpolateStages = YES;
        
        _imageView = [[UIImageView alloc] init];
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.imageView.clipsToBounds = YES;
        [self.contentView addSubview:_imageView];

        _interpolatedImageView = [[UIImageView alloc] init];
        self.interpolatedImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.interpolatedImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.interpolatedImageView.clipsToBounds = YES;
        [self.contentView addSubview:_interpolatedImageView];

        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidReceiveMemoryWarningNotification
                                                          object:nil
                                                           queue:nil
                                                      usingBlock:^(NSNotification * _Nonnull note) {
                                                          // The cache is automatically emptied when the app receives a memory warning so we need to refill the cache so the blur effect still works
                                                          [self updateAsync:YES completion:nil];
                                                      }];
        
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidBecomeActiveNotification
                                                          object:nil
                                                           queue:nil
                                                      usingBlock:^(NSNotification * _Nonnull note) {
                                                          // The cache is automatically emptied when the app enters the background so we need to refill the cache when the app becomes active
                                                          [self updateAsync:YES completion:nil];
                                                      }];
        
        self.cache = [[DBProfileBlurStageCache alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setStage:(NSInteger)stage {
    _stage = stage;
    
    if (stage == 0) {
        _imageView.image = self.initialImage;
    } else {
        UIImage *blurredImage = [self blurredImageForStage:stage];
        if (blurredImage) _imageView.image = blurredImage;
    }
}

- (void)setPercentScrolled:(CGFloat)percentScrolled
{
    _percentScrolled = percentScrolled;
    
    if (!self.isBlurEnabled) return;
    
    self.stage = round(percentScrolled * self.numberOfStages);
    

    // We will use a second image view to interpolate the blur between stages to create a smoother transition
    if (self.shouldInterpolateStages) {
        UIImage *blurredImage = [self blurredImageForStage:self.stage + 1];
        if (blurredImage) _interpolatedImageView.image = blurredImage;
        _interpolatedImageView.alpha = (percentScrolled * self.numberOfStages) - self.stage;
    }
}

- (void)setInitialImage:(UIImage *)initialImage {
    _initialImage = initialImage;
    _imageView.image = initialImage;
    [self updateAsync:YES completion:nil];
}

- (void)tintColorDidChange
{
    [super tintColorDidChange];
    
    // We need to update the cached images to use the new tint color for blurring
    [self updateAsync:YES completion:nil];
}

- (BOOL)shouldUpdate
{
    return self.initialImage != nil;
}

- (CGFloat)blurRadiusForStage:(NSInteger)stage
{
    return stage * (self.maxBlurRadius / self.numberOfStages);
}

- (UIImage *)blurredImageForStage:(CGFloat)stage
{
    return [self.cache blurredImageForImage:self.initialImage
                                  tintColor:self.tintColor
                                      stage:stage];
}

- (void)updateAsync:(BOOL)async completion:(void (^)())completion
{
    if ([self shouldUpdate]) {
        
        [self.cache removeAllObjects];

        UIImage *initialImage = self.initialImage;
        
        void (^block)() = ^void(){
            for (NSInteger stage = 0; stage <= self.numberOfStages; stage++) {
                UIImage *blurredImage = [initialImage blurredImageWithRadius:[self blurRadiusForStage:stage]
                                                                  iterations:self.iterations
                                                                   tintColor:self.tintColor];
                
                [self.cache setBlurredImage:blurredImage
                                   forImage:initialImage
                                  tintColor:self.tintColor
                                      stage:stage];
            }
        };
        
        if (async) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                block();
                dispatch_sync(dispatch_get_main_queue(), ^{
                    if (completion) completion();
                });
            });
        }
        else {
            block();
            if (completion) completion();
        }
    }
    else if (completion) {
        completion();
    }
}

- (void)applyLayoutAttributes:(DBProfileHeaderViewLayoutAttributes *)layoutAttributes
{
    [super applyLayoutAttributes:layoutAttributes];
    
    if (layoutAttributes.headerStyle == DBProfileHeaderStyleDefault) {
        self.blurEnabled = NO;
    }
    
    [self setPercentScrolled:layoutAttributes.percentTransitioned];
}

@end
