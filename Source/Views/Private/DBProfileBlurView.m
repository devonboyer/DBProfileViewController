//
//  DBProfileBlurView.m
//  Pods
//
//  Created by Devon Boyer on 2016-03-25.
//
//

#import "DBProfileBlurView.h"
#import "DBProfileTintedImageView.h"
#import <FXBlurView/FXBlurView.h>

@interface DBBlurStageCacheKey : NSObject

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) UIColor *tintColor;
@property (nonatomic, assign) CGFloat radius;

@end

@implementation DBBlurStageCacheKey

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

@interface DBBlurStageCache : NSCache
@end

@implementation DBBlurStageCache

+ (instancetype)sharedCache {
    static dispatch_once_t pred;
    static id sharedInstance = nil;
    dispatch_once(&pred, ^{
        sharedInstance = [[[self class] alloc] init];
    });
    return sharedInstance;
}

@end

@interface DBProfileBlurView () {
    DBProfileTintedImageView *_imageView;
}

@end

@implementation DBProfileBlurView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.clipsToBounds = YES;
        self.backgroundColor = [UIColor whiteColor];
        self.tintColor = [UIColor clearColor];

        self.maxBlurRadius = 80.0;
        self.iterations = 3;
        self.numberOfStages = 20;
        
        _imageView = [[DBProfileTintedImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _imageView.clipsToBounds = YES;
        [self addSubview:_imageView];
        
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidReceiveMemoryWarningNotification
                                                          object:nil
                                                           queue:nil
                                                      usingBlock:^(NSNotification * _Nonnull note) {
                                                          [self updateAsynchronously:NO completion:nil];
                                                      }];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setStage:(NSInteger)stage {
    _stage = stage;
    
    UIImage *snapshot = [self snapshotOfUnderlyingView];
    UIImage *blurredImage = [self blurredSnapshot:snapshot radius:[self blurRadiusForStage:stage]];
    if (blurredImage) _imageView.image = blurredImage;
}

- (void)setSnapshot:(UIImage *)snapshot {
    _snapshot = snapshot;
    [self updateAsynchronously:YES completion:nil];
}

- (void)setTintColor:(UIColor *)tintColor
{
    [super setTintColor:tintColor];
    if (self.snapshot) [self updateAsynchronously:YES completion:nil];
}

- (UIView *)underlyingView
{
    return self.superview;
}

- (UIImage *)snapshotOfUnderlyingView
{
    return self.snapshot;
}

- (BOOL)shouldUpdate
{
    return YES;
}

- (CGFloat)blurRadiusForStage:(NSInteger)stage
{
    return stage * (self.maxBlurRadius / self.numberOfStages);
}

- (UIImage *)blurredSnapshot:(UIImage *)snapshot radius:(CGFloat)radius
{
    DBBlurStageCacheKey *key = [[DBBlurStageCacheKey alloc] initWithImage:snapshot
                                                                tintColor:self.tintColor
                                                                   radius:radius];
    return [[DBBlurStageCache sharedCache] objectForKey:key];
}

- (void)updateAsynchronously:(BOOL)async completion:(void (^)())completion
{
    if ([self shouldUpdate]) {
        UIImage *snapshot = [self snapshotOfUnderlyingView];
        
        void (^block)() = ^void(){
            for (NSInteger stage = 0; stage < self.numberOfStages; stage++) {
                DBBlurStageCacheKey *key = [[DBBlurStageCacheKey alloc] initWithImage:snapshot
                                                                            tintColor:self.tintColor
                                                                               radius:[self blurRadiusForStage:stage]];
                UIImage *blurredImage = [snapshot blurredImageWithRadius:[self blurRadiusForStage:stage]
                                                              iterations:self.iterations
                                                               tintColor:self.tintColor];
                [[DBBlurStageCache sharedCache] setObject:blurredImage forKey:key];
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

@end
